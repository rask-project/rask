rask_add_qml_module(Window
    URI Rask.Window
    PUBLIC_HEADERS
        NativeWindow.h
        GlassEffect.h
    SOURCES
        NativeWindow.cpp
        GlassEffect.cpp
        MacWindowEffects_p.h
    APPLE_SOURCES
        MacWindowEffects.mm
    OTHER_SOURCES
        MacWindowEffects_stub.cpp
    QML_FILES
        GlassSurface.qml
    PUBLIC_LIBRARIES
        Qt6::Gui
        Qt6::Quick
    APPLE_LIBRARIES
        "-framework AppKit"
        "-framework QuartzCore"
)
