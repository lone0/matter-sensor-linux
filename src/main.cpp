#include "CommandJsonSensorProvider.h"
#include "Config.h"
#include "MatterReporter.h"
#include "SensorPoller.h"

#include <AppMain.h>
#include <lib/support/logging/CHIPLogging.h>
#include <platform/ConnectivityManager.h>

#include <memory>
#include <string>
#include <vector>

namespace {

std::unique_ptr<matter_sensor::CommandJsonSensorProvider> sProvider;
std::unique_ptr<matter_sensor::SensorPoller> sPoller;
matter_sensor::MatterReporter sReporter;

bool ParseApplicationArguments(int argc, char * argv[], std::string & configurationPath, std::vector<char *> & chipArguments)
{
    configurationPath = "/etc/matter-temperature-humidity-sensor.conf";
    chipArguments.clear();
    chipArguments.push_back(argv[0]);
    for (int index = 1; index < argc; ++index)
    {
        if (std::string(argv[index]) == "--sensor-config")
        {
            if (index + 1 >= argc)
            {
                return false;
            }
            configurationPath = argv[++index];
            continue;
        }
        chipArguments.push_back(argv[index]);
    }
    return true;
}

} // namespace

void ApplicationInit()
{
    // The configuration is parsed before CHIP starts so invalid sensor setup cannot commission a non-reporting device.
}

void ApplicationShutdown()
{
    if (sPoller)
    {
        sPoller->Stop();
    }
}

int main(int argc, char * argv[])
{
    std::string configurationPath;
    std::vector<char *> chipArguments;
    if (!ParseApplicationArguments(argc, argv, configurationPath, chipArguments))
    {
        return 1;
    }

    matter_sensor::AppConfig configuration;
    std::string error;
    if (!matter_sensor::LoadConfig(configurationPath, configuration, error))
    {
        ChipLogError(AppServer, "Invalid sensor configuration: %s", error.c_str());
        return 1;
    }

    if (ChipLinuxAppInit(static_cast<int>(chipArguments.size()), chipArguments.data()) != 0)
    {
        return 1;
    }

    const CHIP_ERROR bleError = chip::DeviceLayer::ConnectivityMgr().SetBLEAdvertisingEnabled(false);
    if (bleError != CHIP_NO_ERROR)
    {
        ChipLogError(AppServer, "Could not disable BLE advertising: %" CHIP_ERROR_FORMAT, bleError.Format());
    }

    sProvider = std::make_unique<matter_sensor::CommandJsonSensorProvider>(
        configuration.sensorCommand, configuration.commandTimeout, configuration.maximumOutputBytes);
    sPoller = std::make_unique<matter_sensor::SensorPoller>(
        *sProvider, configuration.pollInterval, [](const matter_sensor::SensorReading & reading) { sReporter.Publish(reading); },
        [](const std::string & message) { ChipLogError(AppServer, "Sensor read failed: %s", message.c_str()); });
    sPoller->Start();

    ChipLinuxAppMainLoop();
    return 0;
}
