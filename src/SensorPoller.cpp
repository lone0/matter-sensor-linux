#include "SensorPoller.h"

#include <string>

namespace matter_sensor {

SensorPoller::SensorPoller(SensorProvider & provider, std::chrono::seconds interval, ReadingHandler onReading,
                           ErrorHandler onError) :
    mProvider(provider),
    mInterval(interval),
    mOnReading(std::move(onReading)),
    mOnError(std::move(onError))
{}

SensorPoller::~SensorPoller()
{
    Stop();
}

void SensorPoller::Start()
{
    if (!mThread.joinable())
    {
        mStopping = false;
        mThread   = std::thread(&SensorPoller::Run, this);
    }
}

void SensorPoller::Stop()
{
    mStopping = true;
    mWaitCondition.notify_all();
    if (mThread.joinable())
    {
        mThread.join();
    }
}

void SensorPoller::Run()
{
    while (!mStopping)
    {
        SensorReading reading{};
        std::string error;
        if (mProvider.Read(reading, error))
        {
            mOnReading(reading);
        }
        else
        {
            mOnError(error);
        }

        std::unique_lock<std::mutex> lock(mWaitMutex);
        mWaitCondition.wait_for(lock, mInterval, [this] { return mStopping.load(); });
    }
}

} // namespace matter_sensor
