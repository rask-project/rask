rask_add_qml_module(Platform
    URI Rask.Platform
    PUBLIC_HEADERS
        Appearance.h
        SystemColors.h
    SOURCES
        Appearance.cpp
        SystemColors.cpp
        SystemColors_p.h
        MacSystemColors.mm
    PUBLIC_LIBRARIES
        Qt6::Gui
    LIBRARIES
        "-framework AppKit"
)
