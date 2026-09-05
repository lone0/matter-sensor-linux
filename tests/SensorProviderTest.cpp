#include "CommandJsonSensorProvider.h"
#include "SensorPoller.h"
#include "SensorProvider.h"
#include "SensorReading.h"
#include "SensorReadingFilter.h"

#include <chrono>
#include <cmath>
#include <cstdlib>
#include <condition_variable>
#include <iostream>
#include <optional>
#include <mutex>
#include <string>
#include <vector>

namespace {

void Require(bool condition, const std::string & message)
{
    if (!condition)
    {
        std::cerr << "FAIL: " << message << '\n';
        std::exit(1);
    }
}

void RequireParse(const std::string & json, int16_t temperature, uint16_t humidity,
                  std::optional<uint32_t> sequence = std::nullopt)
{
    matter_sensor::SensorReading reading{};
    std::string error;
    Require(matter_sensor::ParseSensorReadingJson(json, reading, error), error);
    Require(reading.TemperatureCentiDegrees() == temperature, "temperature conversion");
    Require(reading.HumidityCentiPercent() == humidity, "humidity conversion");
    Require(reading.publicationSequence == sequence, "sequence conversion");
}

void RequireFilter(matter_sensor::SensorReadingFilter & filter, const matter_sensor::SensorReading & sample,
                   bool expectedPublish, std::optional<double> expectedTemperature = std::nullopt,
                   std::optional<double> expectedHumidity = std::nullopt)
{
    matter_sensor::SensorReading filtered{};
    Require(filter.ShouldPublish(sample, filtered) == expectedPublish, "unexpected report decision");
    if (expectedPublish && expectedTemperature.has_value())
    {
        Require(std::abs(filtered.temperatureCelsius - *expectedTemperature) < 0.000001, "filtered temperature");
    }
    if (expectedPublish && expectedHumidity.has_value())
    {
        Require(std::abs(filtered.humidityPercent - *expectedHumidity) < 0.000001, "filtered humidity");
    }
}

class SequencedSensorProvider final : public matter_sensor::SensorProvider
{
public:
    explicit SequencedSensorProvider(std::vector<matter_sensor::SensorReading> readings) : mReadings(std::move(readings)) {}

    bool Read(matter_sensor::SensorReading & reading, std::string & error) override
    {
        (void) error;
        if (mReadings.empty())
        {
            return false;
        }
        if (mIndex < mReadings.size())
        {
            reading = mReadings[mIndex++];
            mLastReading = reading;
            return true;
        }
        reading = mLastReading;
        return true;
    }

private:
    std::vector<matter_sensor::SensorReading> mReadings;
    size_t mIndex = 0;
    matter_sensor::SensorReading mLastReading{};
};

} // namespace

int main()
{
    RequireParse(R"({"temperature_c":23.45,"humidity_percent":56.78})", 2345, 5678);
    RequireParse(R"({"humidity_percent":50.0,"temperature_c":-1.25})", -125, 5000);
    RequireParse(R"({"temperature_c":23.45,"humidity_percent":56.78,"sequence":7})", 2345, 5678, 7U);

    matter_sensor::SensorReading reading{};
    std::string error;
    Require(!matter_sensor::ParseSensorReadingJson(R"({"temperature_c":23,"humidity_percent":100.01})", reading, error),
            "humidity above 100 must be rejected");
    Require(!matter_sensor::ParseSensorReadingJson(R"({"temperature_c":-274,"humidity_percent":50})", reading, error),
            "temperature below absolute zero must be rejected");
    Require(!matter_sensor::ParseSensorReadingJson(R"({"temperature_c":23,"humidity_percent":"50"})", reading, error),
            "string measurement must be rejected");

    matter_sensor::CommandJsonSensorProvider stub({ "tests/fixtures/stub-sensor.sh" }, std::chrono::seconds(1), 128);
    Require(stub.Read(reading, error), error);
    Require(reading.TemperatureCentiDegrees() == 2345 && reading.HumidityCentiPercent() == 5678 &&
                reading.publicationSequence == 1U,
            "stub command measurement");

    matter_sensor::SensorReadingFilter filter;
    RequireFilter(filter, { 20.0, 50.0, 1U }, true, 20.0, 50.0);
    RequireFilter(filter, { 20.08, 50.08, 1U }, false);
    RequireFilter(filter, { 20.08, 50.08, 2U }, false, 20.04, 50.04);
    RequireFilter(filter, { 20.40, 50.08, 3U }, true, 20.24, 50.08);
    RequireFilter(filter, { 20.40, 50.40, 4U }, true, 20.40, 50.24);

    SequencedSensorProvider pollerProvider({
        { 20.0, 50.0, 1U },
        { 100.0, 100.0, 1U },
        { 100.0, 100.0, 1U },
        { 24.0, 54.0, 2U },
    });
    std::mutex pollerMutex;
    std::condition_variable pollerCondition;
    std::vector<matter_sensor::SensorReading> published;
    matter_sensor::SensorPoller poller(
        pollerProvider, std::chrono::seconds(0),
        [&](const matter_sensor::SensorReading & sample) {
            std::lock_guard<std::mutex> lock(pollerMutex);
            published.push_back(sample);
            pollerCondition.notify_all();
        },
        [&](const std::string & message) {
            Require(false, message);
        });
    poller.Start();
    {
        std::unique_lock<std::mutex> lock(pollerMutex);
        Require(pollerCondition.wait_for(lock, std::chrono::milliseconds(250), [&] { return published.size() >= 2; }),
                "poller did not publish fresh sequence");
    }
    poller.Stop();
    Require(published.size() == 2, "poller published stale samples");
    Require(std::abs(published[1].temperatureCelsius - 22.0) < 0.000001, "fresh sequence temperature");
    Require(std::abs(published[1].humidityPercent - 52.0) < 0.000001, "fresh sequence humidity");

    matter_sensor::CommandJsonSensorProvider failed({ "/bin/sh", "-c", "exit 2" }, std::chrono::seconds(1), 128);
    Require(!failed.Read(reading, error), "nonzero command exit must fail");

    matter_sensor::CommandJsonSensorProvider timeout({ "/bin/sh", "-c", "sleep 2" }, std::chrono::milliseconds(20), 128);
    Require(!timeout.Read(reading, error), "slow command must time out");

    matter_sensor::CommandJsonSensorProvider oversized({ "/bin/sh", "-c", "printf '%0200d' 0" },
                                                       std::chrono::seconds(1), 32);
    Require(!oversized.Read(reading, error), "large command output must fail");

    return 0;
}
