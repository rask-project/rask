# Rask

Shared Qt Quick modules for the [rask-project](https://github.com/rask-project)
apps (Konsoll, Metronom, Tekst): the native macOS behaviour they have in
common — translucent windows, blur, system appearance, and more to come —
as QML modules named `Rask.*`, built as shared libraries.

| Module | Types |
|---|---|
| `Rask.Platform` | `Appearance` (singleton): the user's light/dark choice, saved and applied app-wide |
| `Rask.Window` | `NativeWindow`: translucent, blurred window with the content under the title bar, window-button inset, title-bar double click |

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

## Building

Requires Qt 6.10+, CMake 3.21+ and Ninja.

```sh
cmake -B build/Qt_6_12_0_for_macOS_Debug -G Ninja \
  -DCMAKE_PREFIX_PATH=/opt/Qt/6.12.0/macos -DCMAKE_BUILD_TYPE=Debug
cmake --build build/Qt_6_12_0_for_macOS_Debug
ctest --test-dir build/Qt_6_12_0_for_macOS_Debug
open "build/Qt_6_12_0_for_macOS_Debug/examples/window/Rask Window.app"
```

## License

MIT — see [LICENSE](LICENSE).
