#include "CommandJsonSensorProvider.h"
#include "SensorReading.h"
#include "SensorReadingFilter.h"

#include <chrono>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <string>

namespace {

void Require(bool condition, const std::string & message)
{
    if (!condition)
    {
        std::cerr << "FAIL: " << message << '\n';
        std::exit(1);
    }
}

void RequireParse(const std::string & json, int16_t temperature, uint16_t humidity)
{
    matter_sensor::SensorReading reading{};
    std::string error;
    Require(matter_sensor::ParseSensorReadingJson(json, reading, error), error);
    Require(reading.TemperatureCentiDegrees() == temperature, "temperature conversion");
    Require(reading.HumidityCentiPercent() == humidity, "humidity conversion");
}

void RequireFilter(matter_sensor::SensorReadingFilter & filter, const matter_sensor::SensorReading & sample,
                   bool expectedPublish, double expectedTemperature, double expectedHumidity)
{
    matter_sensor::SensorReading filtered{};
    Require(filter.ShouldPublish(sample, filtered) == expectedPublish, "unexpected report decision");
    Require(std::abs(filtered.temperatureCelsius - expectedTemperature) < 0.000001, "filtered temperature");
    Require(std::abs(filtered.humidityPercent - expectedHumidity) < 0.000001, "filtered humidity");
}

} // namespace

int main()
{
    RequireParse(R"({"temperature_c":23.45,"humidity_percent":56.78})", 2345, 5678);
    RequireParse(R"({"humidity_percent":50.0,"temperature_c":-1.25})", -125, 5000);

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
    Require(reading.TemperatureCentiDegrees() == 2345 && reading.HumidityCentiPercent() == 5678,
            "stub command measurement");

    matter_sensor::SensorReadingFilter filter;
    RequireFilter(filter, { 20.0, 50.0 }, true, 20.0, 50.0);
    RequireFilter(filter, { 20.08, 50.08 }, false, 20.04, 50.04);
    RequireFilter(filter, { 20.40, 50.08 }, true, 20.24, 50.08);
    RequireFilter(filter, { 20.40, 50.40 }, true, 20.40, 50.24);

    matter_sensor::CommandJsonSensorProvider failed({ "/bin/sh", "-c", "exit 2" }, std::chrono::seconds(1), 128);
    Require(!failed.Read(reading, error), "nonzero command exit must fail");

    matter_sensor::CommandJsonSensorProvider timeout({ "/bin/sh", "-c", "sleep 2" }, std::chrono::milliseconds(20), 128);
    Require(!timeout.Read(reading, error), "slow command must time out");

    matter_sensor::CommandJsonSensorProvider oversized({ "/bin/sh", "-c", "printf '%0200d' 0" },
                                                       std::chrono::seconds(1), 32);
    Require(!oversized.Read(reading, error), "large command output must fail");

    return 0;
}
