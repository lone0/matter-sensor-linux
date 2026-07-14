#include "MatterReporter.h"

#include <app/clusters/relative-humidity-measurement-server/CodegenIntegration.h>
#include <app/clusters/temperature-measurement-server/CodegenIntegration.h>
#include <lib/support/logging/CHIPLogging.h>
#include <platform/PlatformManager.h>

namespace matter_sensor {
namespace {

constexpr chip::EndpointId kSensorEndpoint = 1;

} // namespace

void MatterReporter::Publish(const SensorReading & reading)
{
    auto * pending = new SensorReading(reading);
    const CHIP_ERROR error =
        chip::DeviceLayer::PlatformMgr().ScheduleWork(PublishOnMatterThread, reinterpret_cast<intptr_t>(pending));
    if (error != CHIP_NO_ERROR)
    {
        delete pending;
        ChipLogError(AppServer, "Could not schedule sensor report: %" CHIP_ERROR_FORMAT, error.Format());
    }
}

void MatterReporter::PublishOnMatterThread(intptr_t context)
{
    const auto * reading = reinterpret_cast<SensorReading *>(context);
    const CHIP_ERROR temperatureError = chip::app::Clusters::TemperatureMeasurement::SetMeasuredValue(
        kSensorEndpoint, chip::app::DataModel::MakeNullable(reading->TemperatureCentiDegrees()));
    const CHIP_ERROR humidityError = chip::app::Clusters::RelativeHumidityMeasurement::SetMeasuredValue(
        kSensorEndpoint, chip::app::DataModel::MakeNullable(reading->HumidityCentiPercent()));
    if (temperatureError != CHIP_NO_ERROR)
    {
        ChipLogError(AppServer, "Could not report temperature: %" CHIP_ERROR_FORMAT, temperatureError.Format());
    }
    if (humidityError != CHIP_NO_ERROR)
    {
        ChipLogError(AppServer, "Could not report humidity: %" CHIP_ERROR_FORMAT, humidityError.Format());
    }
    delete reading;
}

} // namespace matter_sensor
