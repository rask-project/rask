rask_add_qml_module(Window
    URI Rask.Window
    PUBLIC_HEADERS
        NativeWindow.h
    SOURCES
        NativeWindow.cpp
        MacWindowEffects_p.h
    APPLE_SOURCES
        MacWindowEffects.mm
    OTHER_SOURCES
        MacWindowEffects_stub.cpp
    PUBLIC_LIBRARIES
        Qt6::Gui
    APPLE_LIBRARIES
        "-framework AppKit"
)
