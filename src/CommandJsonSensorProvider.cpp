#include "CommandJsonSensorProvider.h"

#include <array>
#include <cerrno>
#include <csignal>
#include <cstring>
#include <fcntl.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

namespace matter_sensor {
namespace {

void CloseFd(int & descriptor)
{
    if (descriptor >= 0)
    {
        close(descriptor);
        descriptor = -1;
    }
}

void TerminateAndReap(pid_t child)
{
    if (child > 0)
    {
        kill(child, SIGKILL);
        while (waitpid(child, nullptr, 0) < 0 && errno == EINTR)
        {
        }
    }
}

} // namespace

CommandJsonSensorProvider::CommandJsonSensorProvider(std::vector<std::string> command, std::chrono::milliseconds timeout,
                                                     size_t maximumOutputBytes) :
    mCommand(std::move(command)), mTimeout(timeout), mMaximumOutputBytes(maximumOutputBytes)
{}

bool CommandJsonSensorProvider::Read(SensorReading & reading, std::string & error)
{
    if (mCommand.empty() || mCommand.front().empty())
    {
        error = "sensor command is empty";
        return false;
    }

    int pipeDescriptors[2] = { -1, -1 };
    if (pipe(pipeDescriptors) != 0)
    {
        error = std::string("cannot create sensor command pipe: ") + std::strerror(errno);
        return false;
    }

    const pid_t child = fork();
    if (child < 0)
    {
        error = std::string("cannot fork sensor command: ") + std::strerror(errno);
        CloseFd(pipeDescriptors[0]);
        CloseFd(pipeDescriptors[1]);
        return false;
    }

    if (child == 0)
    {
        close(pipeDescriptors[0]);
        if (dup2(pipeDescriptors[1], STDOUT_FILENO) < 0)
        {
            _exit(127);
        }
        close(pipeDescriptors[1]);

        std::vector<char *> arguments;
        arguments.reserve(mCommand.size() + 1);
        for (const std::string & argument : mCommand)
        {
            arguments.push_back(const_cast<char *>(argument.c_str()));
        }
        arguments.push_back(nullptr);
        execvp(arguments.front(), arguments.data());
        _exit(127);
    }

    CloseFd(pipeDescriptors[1]);
    const int flags = fcntl(pipeDescriptors[0], F_GETFL, 0);
    if (flags < 0 || fcntl(pipeDescriptors[0], F_SETFL, flags | O_NONBLOCK) < 0)
    {
        error = std::string("cannot configure sensor command pipe: ") + std::strerror(errno);
        CloseFd(pipeDescriptors[0]);
        TerminateAndReap(child);
        return false;
    }

    std::string output;
    bool pipeOpen      = true;
    bool childExited   = false;
    int childStatus    = 0;
    const auto deadline = std::chrono::steady_clock::now() + mTimeout;

    while (pipeOpen || !childExited)
    {
        if (!childExited && waitpid(child, &childStatus, WNOHANG) == child)
        {
            childExited = true;
        }

        const auto now = std::chrono::steady_clock::now();
        if (now >= deadline)
        {
            CloseFd(pipeDescriptors[0]);
            TerminateAndReap(child);
            error = "sensor command timed out";
            return false;
        }
        const auto millisecondsRemaining =
            std::chrono::duration_cast<std::chrono::milliseconds>(deadline - now).count();
        const int waitMilliseconds = static_cast<int>(millisecondsRemaining > 100 ? 100 : millisecondsRemaining);

        pollfd descriptor{ pipeDescriptors[0], POLLIN | POLLHUP, 0 };
        const int pollResult = poll(&descriptor, pipeOpen ? 1 : 0, waitMilliseconds);
        if (pollResult < 0 && errno != EINTR)
        {
            CloseFd(pipeDescriptors[0]);
            TerminateAndReap(child);
            error = std::string("cannot read sensor command output: ") + std::strerror(errno);
            return false;
        }

        if (pipeOpen && pollResult > 0 && (descriptor.revents & (POLLIN | POLLHUP)) != 0)
        {
            std::array<char, 512> buffer;
            for (;;)
            {
                const ssize_t bytesRead = read(pipeDescriptors[0], buffer.data(), buffer.size());
                if (bytesRead > 0)
                {
                    if (output.size() + static_cast<size_t>(bytesRead) > mMaximumOutputBytes)
                    {
                        CloseFd(pipeDescriptors[0]);
                        TerminateAndReap(child);
                        error = "sensor command output exceeds the configured limit";
                        return false;
                    }
                    output.append(buffer.data(), static_cast<size_t>(bytesRead));
                    continue;
                }
                if (bytesRead == 0)
                {
                    CloseFd(pipeDescriptors[0]);
                    pipeOpen = false;
                }
                else if (errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
                {
                    CloseFd(pipeDescriptors[0]);
                    TerminateAndReap(child);
                    error = std::string("cannot read sensor command output: ") + std::strerror(errno);
                    return false;
                }
                break;
            }
        }
    }

    if (!WIFEXITED(childStatus) || WEXITSTATUS(childStatus) != 0)
    {
        error = "sensor command exited unsuccessfully";
        return false;
    }
    return ParseSensorReadingJson(output, reading, error);
}

} // namespace matter_sensor
