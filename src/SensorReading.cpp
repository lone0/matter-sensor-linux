#include "SensorReading.h"

#include <cerrno>
#include <cmath>
#include <cstdlib>
#include <regex>

namespace matter_sensor {
namespace {

constexpr double kMinimumTemperatureCelsius = -273.15;
constexpr double kMaximumTemperatureCelsius = 327.67;
constexpr double kMinimumHumidityPercent = 0.0;
constexpr double kMaximumHumidityPercent = 100.0;
const std::string kNumber = R"(([+-]?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+))(?:[eE][+-]?\d+)?))";
const std::regex kTemperatureThenHumidity(
    "^\\s*\\{\\s*\"temperature_c\"\\s*:\\s*" + kNumber + "\\s*,\\s*\"humidity_percent\"\\s*:\\s*" + kNumber +
    "\\s*\\}\\s*$");
const std::regex kHumidityThenTemperature(
    "^\\s*\\{\\s*\"humidity_percent\"\\s*:\\s*" + kNumber + "\\s*,\\s*\"temperature_c\"\\s*:\\s*" + kNumber +
    "\\s*\\}\\s*$");

bool ParseValue(const std::smatch & matches, bool temperatureFirst, SensorReading & reading, std::string & error)
{
    const auto parseNumber = [](const std::string & value, double & result) {
        errno            = 0;
        char * end       = nullptr;
        result           = std::strtod(value.c_str(), &end);
        return errno != ERANGE && end != value.c_str() && *end == '\0';
    };

    double first  = 0.0;
    double second = 0.0;
    if (!parseNumber(matches[1].str(), first) || !parseNumber(matches[2].str(), second))
    {
        error = "sensor JSON contains a number that cannot be represented";
        return false;
    }
    reading.temperatureCelsius = temperatureFirst ? first : second;
    reading.humidityPercent    = temperatureFirst ? second : first;

    if (!std::isfinite(reading.temperatureCelsius) || !std::isfinite(reading.humidityPercent))
    {
        error = "sensor JSON values must be finite";
        return false;
    }
    if (reading.temperatureCelsius < kMinimumTemperatureCelsius || reading.temperatureCelsius > kMaximumTemperatureCelsius)
    {
        error = "temperature_c is outside the Matter signed centi-degree range";
        return false;
    }
    if (reading.humidityPercent < kMinimumHumidityPercent || reading.humidityPercent > kMaximumHumidityPercent)
    {
        error = "humidity_percent must be between 0 and 100";
        return false;
    }
    return true;
}

} // namespace

int16_t SensorReading::TemperatureCentiDegrees() const
{
    return static_cast<int16_t>(std::lround(temperatureCelsius * 100.0));
}

uint16_t SensorReading::HumidityCentiPercent() const
{
    return static_cast<uint16_t>(std::lround(humidityPercent * 100.0));
}

bool ParseSensorReadingJson(const std::string & json, SensorReading & reading, std::string & error)
{
    std::smatch matches;
    if (std::regex_match(json, matches, kTemperatureThenHumidity))
    {
        return ParseValue(matches, true, reading, error);
    }
    if (std::regex_match(json, matches, kHumidityThenTemperature))
    {
        return ParseValue(matches, false, reading, error);
    }

    error = "sensor command must emit exactly one JSON object with temperature_c and humidity_percent numbers";
    return false;
}

} // namespace matter_sensor
