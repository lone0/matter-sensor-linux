#pragma once

#include <cstdint>
#include <optional>
#include <string>

namespace matter_sensor {

struct SensorReading
{
    double temperatureCelsius;
    double humidityPercent;
    std::optional<uint32_t> publicationSequence;

    int16_t TemperatureCentiDegrees() const;
    uint16_t HumidityCentiPercent() const;
};

bool ParseSensorReadingJson(const std::string & json, SensorReading & reading, std::string & error);

} // namespace matter_sensor
