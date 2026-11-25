#pragma once

#include <QDateTime>

#include <functional>

// The native side of Updater (Sparkle, UpdaterNative.mm).
namespace rask::updaternative
{

[[nodiscard]] bool configured();
// `allowBeta` is asked at each check; `checkFinished` runs after each one.
void start(std::function<bool()> allowBeta, std::function<void()> checkFinished);
[[nodiscard]] bool started();
void checkForUpdates();
[[nodiscard]] bool automaticChecks();
void setAutomaticChecks(bool enabled);
[[nodiscard]] bool automaticDownloads();
void setAutomaticDownloads(bool enabled);
// Drops an update found for the previous channel.
void resetUpdateCycle();
[[nodiscard]] QDateTime lastCheck();

} // namespace rask::updaternative
