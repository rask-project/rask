#pragma once

#include <QString>
#include <QStringList>
#include <QWindow>

#include <functional>

// The native side of Rask.Dialogs: AppKit in NativeDialogs.mm, no-ops in
// NativeDialogs_stub.cpp on other platforms.
namespace rask::nativedialogs
{

[[nodiscard]] bool supported() noexcept;

// The standard About panel. Empty strings keep the panel's defaults (the
// bundle's name, version and NSHumanReadableCopyright).
void showAboutPanel(const QString &applicationName, const QString &version, const QString &copyright);

// The "About Qt" alert: the Qt version in use, its licensing and the Qt logo.
void showAboutQt();

// An NSAlert; `done` gets the index of the chosen button (-1 when nothing was
// shown). With a window it is a sheet on it and returns at once; otherwise it
// is app-modal and `done` runs before it returns.
void showAlert(
    QWindow *window,
    qint32 style,
    const QString &text,
    const QString &informativeText,
    const QStringList &buttons,
    const std::function<void(qint32 button)> &done
);

} // namespace rask::nativedialogs
