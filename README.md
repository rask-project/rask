# Rask

Shared Qt Quick modules for the [rask-project](https://github.com/rask-project)
apps (Konsoll, Metronom, Tekst): the native macOS behaviour they have in
common — translucent windows, blur, system appearance, and more to come —
as QML modules named `Rask.*`, built as shared libraries.

![The Settings example: a blurred sidebar, sections, switches and the opacity slider live, then the switch to the light theme](docs/images/settings.gif)

| Module | Types |
|---|---|
| `Rask.Platform` | `Appearance` (singleton): the user's light/dark choice, saved and applied app-wide; `SystemColors` (singleton): AppKit's semantic colors (label, text, selection, insertion point, accent, find highlight), following light/dark and the accent |
| `Rask.Window` | `NativeWindow`: translucent, blurred window with the content under the title bar, window-button inset, title-bar double click, represented file and the unsaved-changes dot. `GlassEffect`: native Liquid Glass (macOS 26+) behind a QML item; `GlassSurface`: the same look drawn in QML, the fallback |
| `Rask.Dialogs` | `AboutDialog` (the system About panel), `AboutQtDialog`, `Alert` (`NSAlert`, as a sheet when given a window) |
| `Rask.Updater` | `Updater` (singleton): Sparkle updates, "Check for Updates…" in the app menu, beta channel |
| `Rask.Controls` | System Settings-style controls: `SidebarLayout` (blurred sidebar + opaque content pane), `SidebarItem`, `FormGroup`, `FormRow` (icons come from the app); `SearchBar`, a find and replace bar (the app runs the search); `TabStrip`, tabs in the title bar (wrapping rows, drag to reorder or to another window); `ToolbarGroup`/`ToolbarButton`, a glass capsule of icon buttons in the title bar (system icons: SF Symbols by name) |
| `Rask.Application` | `QuitGuard` (singleton): the app reviews before quitting; `FileOpenHandler` (singleton): files from the Finder and the Dock; `RecentDocuments` (singleton): an Open Recent list, shared with the Dock menu |

macOS only (14.4+, Apple Silicon); features of newer systems report it
(`GlassEffect.supported` is false before macOS 26).

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

### Window: translucency, blur and Liquid Glass

![The window example: light and dark themes, the glass bar and the blur turned off and on, the opacity dragged down and up](docs/images/window.gif)

| Dark | Light |
|---|---|
| ![NativeWindow in the dark theme: Liquid Glass title bar and pill over the blur](docs/images/window-dark.png) | ![NativeWindow in the light theme](docs/images/window-light.png) |

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

| Dark | Light |
|---|---|
| ![Settings, Appearance section, dark](docs/images/settings-appearance-dark.png) | ![Settings, Appearance section, light](docs/images/settings-appearance-light.png) |
| ![Settings, Window section with the blur switch and opacity slider, dark](docs/images/settings-window-dark.png) | ![Settings, Window section, light](docs/images/settings-window-light.png) |

<details>
<summary>Every section, in both themes</summary>

| Dark | Light |
|---|---|
| ![Settings, Keyboard section, dark](docs/images/settings-keyboard-dark.png) | ![Settings, Keyboard section, light](docs/images/settings-keyboard-light.png) |
| ![Settings, Security section with a selected row and leading icons, dark](docs/images/settings-security-dark.png) | ![Settings, Security section, light](docs/images/settings-security-light.png) |
| ![Settings, Updates section bound to the Updater, dark](docs/images/settings-updates-dark.png) | ![Settings, Updates section, light](docs/images/settings-updates-light.png) |

</details>

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
        sections: [{ title: qsTr("General"), iconSource: Qt.resolvedUrl("icons/general.svg") }]

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
selected section gets the accent pill; the content pane is opaque. The icons
are the app's own (a theme icon name or an image URL); SVG icons need the app
to link `Qt6::Svg`. See `examples/settings`.

### Dialogs

![The dialogs example: the save sheet and its answer, the About panel, About Qt, then the light theme with the sheet and an app-modal alert](docs/images/dialogs.gif)

| | Dark | Light |
|---|---|---|
| `Alert` with a window (sheet) | ![Save changes sheet, dark](docs/images/dialogs-sheet-dark.png) | ![Save changes sheet, light](docs/images/dialogs-sheet-light.png) |
| `AboutDialog` | ![The system About panel, dark](docs/images/dialogs-about-dark.png) | ![The system About panel, light](docs/images/dialogs-about-light.png) |
| `AboutQtDialog` | ![The About Qt alert, dark](docs/images/dialogs-about-qt-dark.png) | ![The About Qt alert, light](docs/images/dialogs-about-qt-light.png) |
| `Alert` without a window (app-modal) | ![App-modal alert, dark](docs/images/dialogs-alert-dark.png) | ![App-modal alert, light](docs/images/dialogs-alert-light.png) |

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

### Toolbar

```qml
import Rask.Controls

ToolbarGroup {                                  // a glass capsule, as in Xcode
    x: native.leadingInset + 12                 // NativeWindow
    nativeWindow: native                        // the window stays put under the pointer
    ToolbarButton { icon.name: "chevron.backward"; onClicked: goBack() }
    ToolbarButton { icon.name: "chevron.forward"; onClicked: goForward() }
}
```

`icon.name` is any SF Symbol name (Qt asks the system for it on macOS) or a
freedesktop name Qt maps to one (`go-previous`, `document-save`…).

### Tabs and documents

```qml
import Rask.Application
import Rask.Controls

TabStrip {
    width: parent.width
    height: requiredHeight
    baseSafeTop: root.SafeArea.margins.top
    leadingInset: native.leadingInset           // NativeWindow
    nativeWindow: native
    tabs: documents                             // objects with title, modified, toolTip
    currentIndex: current
    onActivateRequested: index => current = index
    onReorderRequested: (from, to) => moveDocument(from, to)
    onWindowDropRequested: (index, globalX, globalY) => tearOff(index, globalX, globalY)
}

Connections {
    target: FileOpenHandler
    function onFilesOpened(files) { files.forEach(open) }
}

Connections {
    target: QuitGuard                           // ⌘Q, the Dock, logging out
    function onQuitRequested() { reviewUnsaved(() => QuitGuard.quit()) }
}
```

`RecentDocuments.files` feeds an Open Recent menu (`add()` when a file opens).
The Finder offers the app in "Open With" for the types its `Info.plist`
declares (`CFBundleDocumentTypes`). See `examples/documents`.

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

Requires macOS, Xcode command-line tools, Qt 6.10+, CMake 3.21+ and Ninja.

```sh
cmake -B build/Qt_6_12_0_for_macOS_Debug -G Ninja \
  -DCMAKE_PREFIX_PATH=/opt/Qt/6.12.0/macos -DCMAKE_BUILD_TYPE=Debug
cmake --build build/Qt_6_12_0_for_macOS_Debug
ctest --test-dir build/Qt_6_12_0_for_macOS_Debug
open "build/Qt_6_12_0_for_macOS_Debug/examples/window/Rask Window.app"
open "build/Qt_6_12_0_for_macOS_Debug/examples/dialogs/Rask Dialogs.app"
open "build/Qt_6_12_0_for_macOS_Debug/examples/settings/Rask Settings.app"
open "build/Qt_6_12_0_for_macOS_Debug/examples/documents/Rask Documents.app"
```

## Screenshots

The images above come from the examples, taken by
`tools/screenshots/take-all.sh` (it drives them with `shoot.sh`: a colour
backdrop, clicks, captures and ffmpeg). Retake them when an example's look
changes; the terminal running it needs Screen Recording and Accessibility.

## License

MIT — see [LICENSE](LICENSE).
