#pragma once

#include "SensorReading.h"

#include <string>

namespace matter_sensor {

class SensorProvider
{
public:
    virtual ~SensorProvider() = default;
    virtual bool Read(SensorReading & reading, std::string & error) = 0;
};

} // namespace matter_sensor
