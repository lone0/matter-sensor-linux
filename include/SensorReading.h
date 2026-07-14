#pragma once

#include <cstdint>
#include <string>

namespace matter_sensor {

struct SensorReading
{
    double temperatureCelsius;
    double humidityPercent;

    int16_t TemperatureCentiDegrees() const;
    uint16_t HumidityCentiPercent() const;
};

bool ParseSensorReadingJson(const std::string & json, SensorReading & reading, std::string & error);

} // namespace matter_sensor
