# Rask

Shared Qt Quick modules for the [rask-project](https://github.com/rask-project)
apps (Konsoll, Metronom, Tekst): the native macOS behaviour they have in
common — translucent windows, blur, system appearance, and more to come —
as QML modules named `Rask.*`, built as shared libraries.

| Module | Types |
|---|---|
| `Rask.Platform` | `Appearance` (singleton): the user's light/dark choice, saved and applied app-wide |
| `Rask.Window` | `NativeWindow`: translucent, blurred window with the content under the title bar, window-button inset, title-bar double click. `GlassEffect`: native Liquid Glass (macOS 26+) behind a QML item; `GlassSurface`: the same look drawn in QML, the fallback |
| `Rask.Dialogs` | `AboutDialog` (the system About panel), `AboutQtDialog`, `Alert` (`NSAlert`, as a sheet when given a window) |
| `Rask.Updater` | `Updater` (singleton): Sparkle updates, "Check for Updates…" in the app menu, beta channel |
| `Rask.Controls` | System Settings-style controls: `SidebarLayout` (blurred sidebar + opaque content pane), `SidebarItem`, `FormGroup`, `FormRow`, and badge icons (`qrc:/qt/qml/Rask/Controls/icons/*.svg`) |

Everything builds on macOS, Linux and Android; outside macOS the native parts
are no-ops and report it (`NativeWindow.translucent` is false).

## Using it in an app

Add the repository as a submodule and link the modules:

```cmake
add_subdirectory(external/rask)

target_link_libraries(myapp PRIVATE Rask::Platform Rask::Window)
# macOS: copy the libraries into the bundle (before the app's own signing step).
rask_embed_libraries(myapp LIBRARIES Rask::Platform Rask::Window)
```

```qml
import Rask.Platform
import Rask.Window

ApplicationWindow {
    id: root
    flags: Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
    color: "transparent"

    NativeWindow {
        window: root
        color: Appearance.dark ? "#1c1c1e" : "#f5f5f7"
        alpha: 0.8
    }
}
```

Linking the library is enough for QML to find the module: its `qmldir` is in
the library's resources (`qrc:/qt/qml`), so the QML plugin is never loaded.
An installed copy works with `find_package(Rask)` as well.

### Liquid Glass

```qml
import Rask.Window

Item {                       // e.g. a tab strip
    GlassEffect { id: glass; anchors.fill: parent; visible: supported; cornerRadius: 0 }
    GlassSurface { anchors.fill: parent; visible: !glass.supported; radius: 0 }
}
```

The native glass view sits behind the Qt content (above the window blur) and
follows the item's geometry, visibility and opacity every frame; QML drawn
over the item shows on top of it. It needs a `NativeWindow`.

Title-bar content (a tab strip, a glass bar) goes at `y: 0` with the height
of the toolbar area, `Math.max(window.SafeArea.margins.top, 40)`, starting
after `NativeWindow.leadingInset`. An `ApplicationWindow` pads its content by
the safe area since Qt 6.9, which pushes it below the toolbar: set
`topPadding: 0` (or use a plain `Window`, as Konsoll does).

### Settings windows

```qml
import Rask.Controls
import Rask.Window

Window {
    id: window
    flags: Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
    color: "transparent"
    NativeWindow { window: window; color: "#1e1e1e"; alpha: 0.9 }

    SidebarLayout {
        anchors.fill: parent
        titleBarHeight: Math.max(window.SafeArea.margins.top, 28)
        sections: [{ title: qsTr("General"), iconSource: "qrc:/qt/qml/Rask/Controls/icons/window.svg" }]

        ColumnLayout {                       // one page per section
            FormGroup {
                FormRow { label: qsTr("Blur"); showSeparator: false; Switch {} }
                FormRow { label: qsTr("Font"); detail: "Menlo 13 pt"; Button { text: qsTr("Change…") } }
            }
        }
    }
}
```

The sidebar is transparent, so the window's blur shows through it; the
selected section gets the accent pill; the content pane is opaque. See
`examples/settings`.

### Dialogs

```qml
import Rask.Dialogs

AboutDialog { id: about; version: "Version 1.2.0 (abc1234)" }   // empty: from Info.plist
AboutQtDialog { id: aboutQt }

Alert {
    id: saveAlert
    window: root                                   // a sheet; without it, app-modal
    style: Alert.Warning
    text: qsTr("Do you want to save the changes?")
    buttons: [qsTr("Save"), qsTr("Don’t Save"), qsTr("Cancel")]
    onFinished: button => console.log(buttons[button])
}
```

Each has `supported` (false outside macOS): show a QML dialog there.

### Updates

`Rask::Updater` brings Sparkle (downloaded at configure time, checked against
its SHA-256); `rask_embed_libraries()` puts `Sparkle.framework` in the bundle.
The app declares its feed in `Info.plist`:

```cmake
rask_sparkle_plist_keys(MYAPP_SPARKLE_PLIST_KEYS
    FEED_URL "https://raw.githubusercontent.com/rask-project/myapp/appcast/appcast.xml"
    PUBLIC_KEY "<EdDSA public key>")
# Info.plist.in: ${MYAPP_SPARKLE_PLIST_KEYS} inside <dict>
```

```qml
import Rask.Updater

Component.onCompleted: Updater.start()      // once the menu bar exists
```

Without a feed (Debug builds) `Updater.available` is false and nothing runs.

## Building

Requires Qt 6.10+, CMake 3.21+ and Ninja.

```sh
cmake -B build/Qt_6_12_0_for_macOS_Debug -G Ninja \
  -DCMAKE_PREFIX_PATH=/opt/Qt/6.12.0/macos -DCMAKE_BUILD_TYPE=Debug
cmake --build build/Qt_6_12_0_for_macOS_Debug
ctest --test-dir build/Qt_6_12_0_for_macOS_Debug
open "build/Qt_6_12_0_for_macOS_Debug/examples/window/Rask Window.app"
open "build/Qt_6_12_0_for_macOS_Debug/examples/dialogs/Rask Dialogs.app"
open "build/Qt_6_12_0_for_macOS_Debug/examples/settings/Rask Settings.app"
```

## License

MIT — see [LICENSE](LICENSE).
