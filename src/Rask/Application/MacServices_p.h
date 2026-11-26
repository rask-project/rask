#pragma once

#include <QList>
#include <QUrl>

#include <functional>

// The app as the Services provider for NSMessage "openFiles" (MacServices.mm):
// "Open in <App>" on the Finder's context menu, and in Services ▸ of any app
// that sends a file, a folder or a selected path.
namespace rask::macservices
{

// Each request's files (local, existing) go to `open`, with the app brought forward.
void install(std::function<void(const QList<QUrl> &)> open);
void remove();

} // namespace rask::macservices
