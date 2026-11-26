#include "CommandLineTool.h"
#include "MacCommandLineTool_p.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>

namespace rask
{

namespace
{

const QString binDirectory{QStringLiteral("/usr/local/bin")};

QString toolPath(const QString &name)
{
    return QFileInfo{QCoreApplication::applicationDirPath() + QStringLiteral("/../Resources/bin/") + name}
        .canonicalFilePath();
}

QString linkPath(const QString &name)
{
    return binDirectory + QLatin1Char('/') + name;
}

} // namespace

CommandLineTool::CommandLineTool(QObject *parent) : QObject(parent) {}

bool CommandLineTool::isInstalled(const QString &name)
{
    const QString tool{toolPath(name)};
    return !tool.isEmpty() && QFileInfo{linkPath(name)}.canonicalFilePath() == tool;
}

bool CommandLineTool::install(const QString &name)
{
    const QString tool{toolPath(name)};
    const QString link{linkPath(name)};
    const QFileInfo existing{link};
    if (tool.isEmpty() || (existing.exists() && !existing.isSymLink())) {
        return false;
    }
    if (QFileInfo{binDirectory}.isWritable()) {
        if (existing.isSymLink() && !QFile::remove(link)) {
            return false;
        }
        return QFile::link(tool, link);
    }
    return maccommandline::linkAsAdministrator(tool, link) && isInstalled(name);
}

} // namespace rask
