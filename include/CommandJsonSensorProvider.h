#pragma once

#include "SensorProvider.h"

#include <chrono>
#include <string>
#include <vector>

namespace matter_sensor {

class CommandJsonSensorProvider final : public SensorProvider
{
public:
    CommandJsonSensorProvider(std::vector<std::string> command, std::chrono::milliseconds timeout,
                              size_t maximumOutputBytes);

    bool Read(SensorReading & reading, std::string & error) override;

private:
    std::vector<std::string> mCommand;
    std::chrono::milliseconds mTimeout;
    size_t mMaximumOutputBytes;
};

} // namespace matter_sensor
