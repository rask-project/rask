#include "UpdaterNative_p.h"

namespace rask::updaternative
{

bool configured()
{
    return false;
}

void start(std::function<bool()> /*allowBeta*/, std::function<void()> /*checkFinished*/) {}

bool started()
{
    return false;
}

void checkForUpdates() {}

bool automaticChecks()
{
    return false;
}

void setAutomaticChecks(bool /*enabled*/) {}

bool automaticDownloads()
{
    return false;
}

void setAutomaticDownloads(bool /*enabled*/) {}

void resetUpdateCycle() {}

QDateTime lastCheck()
{
    return {};
}

} // namespace rask::updaternative
