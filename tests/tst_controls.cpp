#include "tst_controls.h"

#include <QQmlComponent>
#include <QQmlEngine>
#include <QTest>

#include <memory>

namespace
{

std::unique_ptr<QObject> create(QQmlEngine &engine, const QByteArray &qml)
{
    QQmlComponent component{&engine};
    component.setData(qml, QUrl{QStringLiteral("qrc:/tst_controls.qml")});
    std::unique_ptr<QObject> object{component.create()};
    if (object == nullptr) {
        qWarning().noquote() << component.errorString();
    }
    return object;
}

} // namespace

void TestControls::createsEveryType_data()
{
    QTest::addColumn<QByteArray>("qml");
    QTest::newRow("FormGroup with rows"
    ) << QByteArray{"import QtQuick\nimport QtQuick.Controls\nimport Rask.Controls\n"
                    "FormGroup { FormRow { label: \"A\"; showSeparator: false; Switch {} }"
                    " FormRow { label: \"B\"; detail: \"d\"; selectable: true; highlighted: true } }"};
    QTest::newRow("SidebarItem with a theme icon")
        << QByteArray{"import Rask.Controls\n"
                      "SidebarItem { title: \"General\"; selected: true; badge: \"3\"; iconName: \"general\" }"};
    QTest::newRow("SearchBar replacing"
    ) << QByteArray{"import Rask.Controls\n"
                    "SearchBar { width: 600; text: \"x\"; replacing: true; matchCount: 3; currentMatch: 1 }"};
    QTest::newRow("TabStrip with tabs"
    ) << QByteArray{"import Rask.Controls\n"
                    "TabStrip { width: 900; leadingInset: 80; currentIndex: 1;"
                    " tabs: [{ title: \"a.txt\" }, { title: \"b.cpp\", modified: true }] }"};
}

void TestControls::createsEveryType()
{
    QFETCH(const QByteArray, qml);
    QQmlEngine engine;
    QVERIFY(create(engine, qml) != nullptr);
}

void TestControls::sidebarLayoutFollowsSelection()
{
    QQmlEngine engine;
    const std::unique_ptr<QObject> layout{create(
        engine,
        "import QtQuick\nimport Rask.Controls\n"
        "SidebarLayout { width: 720; height: 480;"
        " sections: [{ title: \"One\", iconName: \"x\" }, { title: \"Two\" }];"
        " Item {} Item {} }"
    )};
    QVERIFY(layout != nullptr);
    QCOMPARE(layout->property("currentTitle").toString(), QStringLiteral("One"));
    layout->setProperty("currentIndex", 1);
    QCOMPARE(layout->property("currentTitle").toString(), QStringLiteral("Two"));
}

void TestControls::tabStripWrapsAndPlacesDrops()
{
    QQmlEngine engine;
    const std::unique_ptr<QObject> strip{create(
        engine,
        "import Rask.Controls\n"
        "TabStrip { width: 400; leadingInset: 80; currentIndex: 0;"
        " tabs: [{ title: \"1\" }, { title: \"2\" }, { title: \"3\" }, { title: \"4\" }, { title: \"5\" }] }"
    )};
    QVERIFY(strip != nullptr);
    QVERIFY(strip->property("rowCount").toInt() > 1);
    QVERIFY(strip->property("requiredHeight").toReal() > 40.0);
    QVariant index;
    QVERIFY(QMetaObject::invokeMethod(
        strip.get(),
        "insertionIndexAtGlobal",
        Q_RETURN_ARG(QVariant, index),
        Q_ARG(QVariant, 0.0),
        Q_ARG(QVariant, 0.0)
    ));
    QCOMPARE(index.toInt(), 0);
}

QTEST_MAIN(TestControls)
