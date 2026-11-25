# AGENTS.md

Guidance for AI agents working in this repository.

## Project

- Rask — shared Qt Quick modules (`Rask.*`) for the rask-project apps:
  Konsoll (`../konsoll`), Metronom (`../metronom`) and Tekst (`../tekst`).
- Toolchain: C++23, Qt ≥ 6.10 (developed on 6.12), CMake ≥ 3.21 + Ninja.
- Platform: **macOS only** (14.4+, Apple Silicon). There are no stubs or
  fallbacks for other systems; the top-level `CMakeLists.txt` refuses to
  configure elsewhere. An app that also targets other platforms (Metronom)
  links `rask` on macOS only and keeps its own code for the others.
- Only what at least one app uses goes here, and nothing app-specific (no
  "terminal", "session", "document", "metronome"). A feature moves here when
  a second app needs it, or when it unifies what apps already duplicate.

## Structure

- `CMakeLists.txt` — project `Rask`, the modules, examples and tests
  (`RASK_BUILD_EXAMPLES` / `RASK_BUILD_TESTS`, on when built on its own),
  install/export for `find_package(Rask)`.
- `cmake/RaskModule.cmake` — `rask_add_qml_module()`: one call per module.
- `cmake/RaskApp.cmake` — helpers for apps: `rask_embed_libraries()` (dylibs
  and the frameworks they need, e.g. Sparkle) and `rask_sparkle_plist_keys()`.
- `cmake/RaskSparkle.cmake` — downloads Sparkle (pinned version + SHA-256)
  into the build tree; used by `Rask.Updater`.
- `src/Rask/<Module>/` — one directory per module (the path matches the URI):
  - `Rask.Platform` — `Appearance` (QML singleton; QSettings
    `appearance/colorScheme`, applied with `QStyleHints::setColorScheme`),
    `SystemColors` (QML singleton; semantic `NSColor`s resolved for
    `NSApp.effectiveAppearance`, refreshed on `colorSchemeChanged` and
    `NSSystemColorsDidChangeNotification`).
  - `Rask.Window` — `NativeWindow` (translucency, blur, unified toolbar,
    `leadingInset`, movable, title-bar double click), `GlassEffect` (a
    `QQuickItem` driving an `NSGlassEffectView`, macOS 26+, inside one
    `NSGlassEffectContainerView` per window between the blur and the Qt
    content view; synced on `afterAnimating`, so nothing per frame when
    unchanged) and `GlassSurface.qml` (the QML-drawn fallback: static, nothing
    animated). AppKit in `MacWindowEffects.mm`.
  - `Rask.Dialogs` — `AboutDialog` (`orderFrontStandardAboutPanel`),
    `AboutQtDialog` (`NSAlert` + `qtlogo-64.png` in the module's resources),
    `Alert` (`NSAlert`; sheet with a window, app-modal without). AppKit in
    `NativeDialogs.mm`.
  - `Rask.Updater` — `Updater` (QML singleton backed by a function-local
    static, `Updater::shared()`): Sparkle's `SPUStandardUpdaterController`,
    beta channel in QSettings `Updates/betaUpdates`, "Check for Updates…"
    added natively to the app menu. Sparkle objects are retained with
    `CFBridgingRetain` and never released (AppKit may call them during quit).
    Sparkle in `UpdaterNative.mm`.
  - `Rask.Controls` — QML only: `SidebarLayout` (System Settings layout:
    transparent sidebar over the window blur, opaque content pane, section
    title beside the window buttons), `SidebarItem`, `FormGroup`, `FormRow`
    (from Konsoll's Settings window). No icons or other app assets: apps
    pass their own (`iconName` / `iconSource`). Colors
    follow `Application.styleHints` (typed, so qmllint can check it); the
    selected sidebar row uses the delegate's own `palette.highlight`.
- `examples/<name>/` — small apps (`window`, `dialogs`, `settings`), built as bundles
  that embed the libraries like a real app does. Modal panels and sheets are
  checked by hand there; tests cover properties only.
- `tests/` — QtTest, run offscreen with `ctest`.

## Build and run

```sh
cmake -B build/Qt_6_12_0_for_macOS_Debug -G Ninja \
  -DCMAKE_PREFIX_PATH=/opt/Qt/6.12.0/macos -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build/Qt_6_12_0_for_macOS_Debug
ctest --test-dir build/Qt_6_12_0_for_macOS_Debug --output-on-failure
open "build/Qt_6_12_0_for_macOS_Debug/examples/window/Rask Window.app"
```

## Modules and the shared-library contract

- **Every module is a shared library** made by `rask_add_qml_module()`:
  target `rask_<name>`, alias `Rask::<Name>`, file `libRask<Name>.<major>.dylib`,
  QML URI `Rask.<Name>`. Never call `qt_add_library`/`qt_add_qml_module`
  directly for a module.
- **Symbols are hidden by default.** A class or function apps use carries the
  module's export macro (`RASK_WINDOW_EXPORT` from
  `<Rask/Window/raskwindow_export.h>`). Anything else stays unexported.
- **Public headers** (`PUBLIC_HEADERS`) are the API: included as
  `<Rask/<Module>/Header.h>` and installed. Private headers end in `_p.h`
  and are never installed or included by apps.
- **Native code** sits behind a private C++ header (`*_p.h`) with plain
  functions, implemented in a `.mm` (listed in `SOURCES`, compiled with ARC).
  The QML type calls them; Objective-C stays out of public headers.
- **Versioning:** `VERSION`/`SOVERSION` come from `project(Rask VERSION …)`.
  A change that breaks a public C++ signature, a class layout of an exported
  class, or a QML property/type bumps the major version.
- **Apps link the backing library**; the QML plugin stays optional and is
  not loaded (the `qmldir` is in the library's resources). Keep the generated
  plugin: no custom plugin class, no `NO_PLUGIN_OPTIONAL`.
- **Bundling:** apps call `rask_embed_libraries()` before their own bundle
  signing; it copies and signs the dylibs into `Contents/Frameworks` and
  sets the rpath. A module that needs a third-party framework sets the
  target property `RASK_EMBED_FRAMEWORKS` (see `Rask.Updater`), and the
  framework is copied with `ditto`, keeping its own signature. Each example
  does the same, so the examples are the check.
- **`-Wpadded`** is set on each module's own `.cpp`/`.mm` sources (Debug), not
  on targets or project-wide: Qt's generated code (qmlcachegen output for a
  module's QML files, the examples) would trip it. Headers are still checked
  through the sources that include them.

## Conventions

- **Language:** respond in Portuguese. Code, comments and commit messages in
  English.
- **Comments:** minimal — names speak for themselves; at most one short line
  when the "why" is not obvious. Public headers document each type and each
  non-obvious property in one or two lines.
- **Design:** minimal solutions, no speculative fields or options: a
  property exists because an app binds it.
- No debug logging (`qDebug`) left in committed code.
- **Commits and PRs:** never add `Co-authored-by` (or any other AI
  attribution trailer, e.g. "Generated with") to commit messages or pull
  request descriptions. The author is the repository owner.

## C++ rules

- **C++23** is required (enforced in `CMakeLists.txt`).
- **Ownership:** every owned object has exactly one owner, a
  `std::unique_ptr` (or a plain value member). Ownership moves with
  `std::move`; code that only uses an object gets a non-owning `const T *`
  (or a reference) and never keeps it past the owner's lifetime. QObject
  children owned by their Qt parent are fine.
- **`std::shared_ptr` is forbidden** (and with it `std::make_shared`,
  `std::weak_ptr`, `QSharedPointer`). If the logic seems to need shared
  ownership, rethink it so one object owns the thing and the others borrow it.
- **Raw pointers are forbidden** — no `new`/`delete`, no owning raw pointers.
  Exceptions: the non-owning `const T *` above, and non-owning pointers
  required by C/POSIX/Qt/AppKit APIs. Wrap C handles in `std::unique_ptr`
  with a custom deleter. Qt Quick scene-graph nodes are the one ownership
  hand-off (`std::make_unique` + `release()` to the parent node).
- **Exceptions are forbidden** — no `throw`, `try` or `catch` anywhere.
- **Error handling:** fallible operations return `std::expected<T, E>` with a
  concrete error type (or `bool`/`std::optional` when there is nothing to
  report).
- **Types:** use Qt's typedefs, never the `<cstdint>` ones: `qint8`…`qint64`
  / `quint8`…`quint64` for fixed width, `qsizetype` for sizes and indices,
  `qreal` for geometry. Integers are `qint32` instead of `int`, `Q_PROPERTY`
  included (QML still sees `int`). Lists are `QList`, not `std::vector`.
  Platform API types (`CGFloat`, `NSInteger`, `jint`, …) stay at the API
  boundary.
- **Initialization:** brace-initialize every variable — data members,
  constants, locals and `for` counters. `=` only where the grammar requires
  it. Exception: a container constructor that takes a size keeps parentheses
  (`QList<qint32> offsets(n);`).
- **Algorithms:** always use `std::ranges` / `<algorithm>` instead of
  hand-rolled loops.
- **Control flow:** early return over nesting; flatten `if`/`else` chains
  with guard clauses.
- **Performance:** move over copy, no needless temporaries; mark `noexcept`
  where it holds.
- **Member ordering / alignment:** order data members from largest alignment
  to smallest (8-byte — pointers, `QPointer`, `qreal` — then 4-byte, then
  1-byte); pack booleans into a flags word. Debug builds enable `-Wpadded`;
  keep it clean (store a colour as `QRgb`, keep state that already lives
  elsewhere — QSettings, the window — out of the object).

## Qt / QML

- Follow Qt idioms: signals/slots, `Q_PROPERTY`, `QML_ELEMENT`.
- C++ types live in `namespace rask`. Setters return early when the value is
  unchanged and only then emit the change signal.
- Configurable native behaviour is a C++ QML type whose properties QML binds;
  QML never reaches into platform code.
- Check <https://doc.qt.io> for component and API behaviour rather than
  guessing.

## Native macOS interop

- On macOS `QWindow::winId()` is the window's `contentView` (`NSView *`), not
  the `NSWindow` — get the window via `[nsView window]`, and only when
  `QGuiApplication::platformName()` is `cocoa` (tests run offscreen).
- Don't call `winId()` before the window has a platform handle
  (`QWindow::handle()`): it would create the native window early.
- Hiding a window drops its `NSWindow`; re-apply native styling when it is
  shown again.
- AppKit colors expect **0.0–1.0** components: use `QColor::redF()`/
  `greenF()`/`blueF()`.
- **Blocks capture C++ references as references.** A block that runs later
  (sheet completion handlers, notifications, dispatch) must capture a local
  copy, never a `const T &` parameter: the referenced object is gone by then
  (a dangling `std::function` throws `bad_function_call` and aborts).
- Menu-bar texts that Qt moves into the app menu ("About…", "Settings…",
  "Quit…") stay in English; other app-menu items are added natively (see
  "Check for Updates…").
- Stacking in the window's frame view, bottom to top: blur
  (`NSVisualEffectView`), glass host (`NSGlassEffectContainerView`), Qt content
  view, window buttons, input-forwarding view. Whatever creates one of them
  later must insert it at its place (see `setBlur`).
- New macOS APIs go behind `@available` / `API_AVAILABLE` and report it
  (`GlassEffect.supported`): the deployment target is macOS 14.4.
- Per-window native objects (effect views, toolbars) are kept on the
  `NSWindow` with `objc_setAssociatedObject`, not in C++ members.

## QML

- Run qmllint on changed QML (`qmllint -I build/…/qml <files>`) and keep it
  clean. Delegates that reach ids outside them need
  `pragma ComponentBehavior: Bound`.
- Modules ship no app assets (icons, images, sounds): apps pass their own.
- Qt modules are found at the top level (`find_package(Qt6 …)` in
  `CMakeLists.txt`): imported targets found in a subdirectory are invisible
  to the examples and tests that link them.

## Screenshots

- The README's images (`docs/images/`) are retaken by
  `tools/screenshots/take-all.sh [window|dialogs|settings]`: one scene per
  example, both themes, a GIF each. It drives the examples with
  `tools/screenshots/shoot.sh` (run it without arguments for its commands): a
  colour backdrop hides the desktop, `launch` places the example with
  `-qwindowgeometry`, `click`/`drag`/`key` act, `shot`/`shot-all` capture,
  `record`/`record-stop` film with ffmpeg, `png`/`gif` optimize.
- Positions in `take-all.sh` are points relative to each example's window,
  measured from captures. When an example's layout changes, re-measure and
  retake; keep example layouts stable (fixed widths) so clicks don't drift.
- Each scene restores the example's saved appearance afterwards.
- The terminal running it needs Screen Recording (captures) and
  Accessibility (clicks and keys), granted to the app that runs the shell;
  macOS applies them after that app restarts.

## Formatting

- **Run `tools/format-code.sh` after every change**, before building or
  committing (clang-format for `.cpp`/`.h`/`.mm`, qmlformat for QML).
  `--check` lists files that need formatting; `--changed` limits it to files
  changed against HEAD.

## clang-tidy

- **Follow the clang-tidy rules proactively** — `.clang-tidy` is the source of
  truth and `WarningsAsErrors: "*"` makes every check an error. No `NOLINT`.
- Verify per file:
  `clang-tidy -p build/Qt_6_12_0_for_macOS_Debug --config-file=.clang-tidy --extra-arg=-isysroot$(xcrun --show-sdk-path) <file>`.
- Test classes are declared in a header (`tst_*.h`), so moc's output is
  compiled on its own instead of being included (and linted) in the test.
- **`.mm` caveat:** clang-tidy 19 segfaults on `.mm` files while running
  `cppcoreguidelines-avoid-const-or-ref-data-members`; run `.mm` files with
  `--checks=-cppcoreguidelines-avoid-const-or-ref-data-members`.
