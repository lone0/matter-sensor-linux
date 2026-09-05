#include "SensorPoller.h"

#include <iomanip>
#include <iostream>
#include <sstream>
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
            if (reading.publicationSequence.has_value() && mLastSequence.has_value() &&
                reading.publicationSequence == mLastSequence)
            {
                std::clog << "Skip: stale RTC sequence=" << *reading.publicationSequence << " repeated"
                          << std::endl;
                std::unique_lock<std::mutex> lock(mWaitMutex);
                mWaitCondition.wait_for(lock, mInterval, [this] { return mStopping.load(); });
                continue;
            }
            if (reading.publicationSequence.has_value())
            {
                mLastSequence = reading.publicationSequence;
            }

            SensorReading filteredReading{};
            if (mReadingFilter.ShouldPublish(reading, filteredReading))
            {
                mOnReading(filteredReading);
            }
            else
            {
                const SensorReading & lastSubmitted = *mReadingFilter.LastSubmitted();
                std::ostringstream log;
                log << std::fixed << std::setprecision(2) << "Skip: average=" << filteredReading.temperatureCelsius
                    << "°C/" << filteredReading.humidityPercent << "% last-submitted="
                    << lastSubmitted.temperatureCelsius << "°C/" << lastSubmitted.humidityPercent << "% delta="
                    << std::showpos
                    << filteredReading.temperatureCelsius - lastSubmitted.temperatureCelsius << "°C/"
                    << filteredReading.humidityPercent - lastSubmitted.humidityPercent << "%" << std::noshowpos;
                std::clog << log.str() << std::endl;
            }
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
