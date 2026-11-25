#include "RecentDocuments.h"

#include "MacRecentDocuments_p.h"

#include <QSettings>

namespace rask
{

namespace
{

const QString filesKey{QStringLiteral("recentDocuments")};

} // namespace

RecentDocuments::RecentDocuments(QObject *parent) : QObject(parent) {}

QList<QUrl> RecentDocuments::files()
{
    const QStringList paths{QSettings{}.value(filesKey).toStringList()};
    QList<QUrl> urls;
    urls.reserve(paths.size());
    std::ranges::transform(paths, std::back_inserter(urls), &QUrl::fromLocalFile);
    return urls;
}

void RecentDocuments::add(const QUrl &file)
{
    if (!file.isLocalFile()) {
        return;
    }
    const QString path{file.toLocalFile()};
    QStringList paths{QSettings{}.value(filesKey).toStringList()};
    if (!paths.isEmpty() && paths.first() == path) {
        return;
    }
    paths.removeAll(path);
    paths.prepend(path);
    if (paths.size() > maximumCount) {
        paths.resize(maximumCount);
    }
    QSettings{}.setValue(filesKey, paths);
    macrecent::note(path);
    emit filesChanged();
}

void RecentDocuments::clear()
{
    QSettings settings;
    if (!settings.contains(filesKey)) {
        return;
    }
    settings.remove(filesKey);
    macrecent::clear();
    emit filesChanged();
}

} // namespace rask
