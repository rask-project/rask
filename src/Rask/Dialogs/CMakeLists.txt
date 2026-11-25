rask_add_qml_module(Dialogs
    URI Rask.Dialogs
    PUBLIC_HEADERS
        AboutDialog.h
        AboutQtDialog.h
        Alert.h
    SOURCES
        AboutDialog.cpp
        AboutQtDialog.cpp
        Alert.cpp
        NativeDialogs_p.h
        NativeDialogs.mm
    RESOURCES
        qtlogo-64.png
    PUBLIC_LIBRARIES
        Qt6::Gui
    LIBRARIES
        "-framework AppKit"
)
