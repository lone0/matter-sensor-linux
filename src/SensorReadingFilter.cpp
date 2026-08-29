#include "SensorReadingFilter.h"

#include <cmath>

namespace matter_sensor {
namespace {

constexpr double kTemperatureAccuracy = 0.2;
constexpr double kHumidityAccuracy = 2.0;

} // namespace

bool SensorReadingFilter::ShouldPublish(const SensorReading & sample, SensorReading & readingToPublish)
{
    if (!mLastSample.has_value() || !mLastSubmitted.has_value())
    {
        mLastSample    = sample;
        mLastSubmitted = sample;
        readingToPublish = sample;
        return true;
    }

    const SensorReading averaged{
        (sample.temperatureCelsius + mLastSample->temperatureCelsius) / 2.0,
        (sample.humidityPercent + mLastSample->humidityPercent) / 2.0,
    };
    readingToPublish = averaged;
    mLastSample = sample;

    const bool temperatureChanged =
        std::abs(averaged.temperatureCelsius - mLastSubmitted->temperatureCelsius) > kTemperatureAccuracy/4;
    const bool humidityChanged = std::abs(averaged.humidityPercent - mLastSubmitted->humidityPercent) > kHumidityAccuracy/4;
    if (!temperatureChanged && !humidityChanged)
    {
        return false;
    }

    mLastSubmitted = averaged;
    return true;
}

const std::optional<SensorReading> & SensorReadingFilter::LastSubmitted() const
{
    return mLastSubmitted;
}

} // namespace matter_sensor
