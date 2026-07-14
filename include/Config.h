#pragma once

#include <chrono>
#include <string>
#include <vector>

namespace matter_sensor {

struct AppConfig
{
    std::vector<std::string> sensorCommand;
    std::chrono::seconds pollInterval{ 60 };
    std::chrono::milliseconds commandTimeout{ 5000 };
    size_t maximumOutputBytes{ 4096 };
};

bool LoadConfig(const std::string & path, AppConfig & config, std::string & error);

} // namespace matter_sensor
