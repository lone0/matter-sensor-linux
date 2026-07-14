#pragma once

#include "SensorReading.h"

namespace matter_sensor {

class MatterReporter
{
public:
    void Publish(const SensorReading & reading);

private:
    static void PublishOnMatterThread(intptr_t context);
};

} // namespace matter_sensor
