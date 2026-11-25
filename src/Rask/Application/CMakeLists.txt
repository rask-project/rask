rask_add_qml_module(Application
    URI Rask.Application
    PUBLIC_HEADERS
        FileOpenHandler.h
        QuitGuard.h
        RecentDocuments.h
    SOURCES
        FileOpenHandler.cpp
        QuitGuard.cpp
        RecentDocuments.cpp
        MacRecentDocuments_p.h
        MacRecentDocuments.mm
    PUBLIC_LIBRARIES
        Qt6::Gui
    LIBRARIES
        "-framework AppKit"
)
