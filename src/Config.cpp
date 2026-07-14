#include "Config.h"

#include <charconv>
#include <fstream>
#include <limits>
#include <string_view>

namespace matter_sensor {
namespace {

std::string Trim(std::string value)
{
    const auto first = value.find_first_not_of(" \t\r\n");
    if (first == std::string::npos)
    {
        return {};
    }
    const auto last = value.find_last_not_of(" \t\r\n");
    return value.substr(first, last - first + 1);
}

bool ParsePositiveNumber(const std::string & value, long long maximum, long long & result)
{
    const char * begin = value.data();
    const char * end   = begin + value.size();
    const auto parsed  = std::from_chars(begin, end, result);
    return parsed.ec == std::errc{} && parsed.ptr == end && result > 0 && result <= maximum;
}

} // namespace

bool LoadConfig(const std::string & path, AppConfig & config, std::string & error)
{
    std::ifstream input(path);
    if (!input)
    {
        error = "cannot open configuration file: " + path;
        return false;
    }

    config.sensorCommand.clear();
    std::string line;
    size_t lineNumber = 0;
    while (std::getline(input, line))
    {
        ++lineNumber;
        line = Trim(std::move(line));
        if (line.empty() || line.front() == '#')
        {
            continue;
        }

        const auto separator = line.find('=');
        if (separator == std::string::npos)
        {
            error = "invalid configuration at line " + std::to_string(lineNumber);
            return false;
        }

        const std::string key   = Trim(line.substr(0, separator));
        const std::string value = Trim(line.substr(separator + 1));
        if (key == "sensor_command")
        {
            if (!config.sensorCommand.empty() || value.empty())
            {
                error = "sensor_command must appear once and must not be empty";
                return false;
            }
            config.sensorCommand.push_back(value);
        }
        else if (key == "sensor_arg")
        {
            if (value.empty())
            {
                error = "sensor_arg must not be empty";
                return false;
            }
            config.sensorCommand.push_back(value);
        }
        else
        {
            long long parsed = 0;
            if (key == "poll_interval_seconds" &&
                ParsePositiveNumber(value, std::numeric_limits<int>::max(), parsed))
            {
                config.pollInterval = std::chrono::seconds(parsed);
            }
            else if (key == "command_timeout_milliseconds" &&
                     ParsePositiveNumber(value, std::numeric_limits<int>::max(), parsed))
            {
                config.commandTimeout = std::chrono::milliseconds(parsed);
            }
            else if (key == "maximum_output_bytes" &&
                     ParsePositiveNumber(value, 1024 * 1024, parsed))
            {
                config.maximumOutputBytes = static_cast<size_t>(parsed);
            }
            else
            {
                error = "invalid or unknown configuration key at line " + std::to_string(lineNumber);
                return false;
            }
        }
    }

    if (config.sensorCommand.empty())
    {
        error = "configuration must define sensor_command";
        return false;
    }
    return true;
}

} // namespace matter_sensor
