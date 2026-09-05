#include "SensorReadingFilter.h"

#include <cmath>

namespace matter_sensor {
namespace {

constexpr double kTemperatureDeadband = 0.1;
constexpr double kHumidityDeadband = 0.5;

} // namespace

bool SensorReadingFilter::ShouldPublish(const SensorReading & sample, SensorReading & readingToPublish)
{
    if (!mLastSample.has_value() || !mLastSubmitted.has_value())
    {
        mLastSample     = sample;
        mLastSubmitted  = sample;
        readingToPublish = sample;
        return true;
    }

    const SensorReading averaged{
        (sample.temperatureCelsius + mLastSample->temperatureCelsius) / 2.0,
        (sample.humidityPercent + mLastSample->humidityPercent) / 2.0,
        std::nullopt,
    };
    readingToPublish = averaged;
    mLastSample = sample;

    const bool temperatureChanged =
        std::abs(averaged.temperatureCelsius - mLastSubmitted->temperatureCelsius) > kTemperatureDeadband;
    const bool humidityChanged =
        std::abs(averaged.humidityPercent - mLastSubmitted->humidityPercent) > kHumidityDeadband;
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
