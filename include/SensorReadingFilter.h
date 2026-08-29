#pragma once

#include "SensorReading.h"

#include <optional>

namespace matter_sensor {

class SensorReadingFilter
{
public:
    bool ShouldPublish(const SensorReading & sample, SensorReading & readingToPublish);
    const std::optional<SensorReading> & LastSubmitted() const;

private:
    std::optional<SensorReading> mLastSample;
    std::optional<SensorReading> mLastSubmitted;
};

} // namespace matter_sensor
