rask_add_qml_module(Window
    URI Rask.Window
    PUBLIC_HEADERS
        NativeWindow.h
        GlassEffect.h
    SOURCES
        NativeWindow.cpp
        GlassEffect.cpp
        MacWindowEffects_p.h
        MacWindowEffects.mm
    QML_FILES
        GlassSurface.qml
    PUBLIC_LIBRARIES
        Qt6::Gui
        Qt6::Quick
    LIBRARIES
        "-framework AppKit"
        "-framework QuartzCore"
)
