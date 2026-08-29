#pragma once

#include "SensorProvider.h"
#include "SensorReadingFilter.h"

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <functional>
#include <mutex>
#include <thread>

namespace matter_sensor {

class SensorPoller
{
public:
    using ReadingHandler = std::function<void(const SensorReading &)>;
    using ErrorHandler = std::function<void(const std::string &)>;

    SensorPoller(SensorProvider & provider, std::chrono::seconds interval, ReadingHandler onReading, ErrorHandler onError);
    ~SensorPoller();

    void Start();
    void Stop();

private:
    void Run();

    SensorProvider & mProvider;
    std::chrono::seconds mInterval;
    ReadingHandler mOnReading;
    ErrorHandler mOnError;
    std::atomic<bool> mStopping{ false };
    std::mutex mWaitMutex;
    std::condition_variable mWaitCondition;
    std::thread mThread;
    SensorReadingFilter mReadingFilter;
};

} // namespace matter_sensor
