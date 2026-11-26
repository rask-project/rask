rask_add_qml_module(Application
    URI Rask.Application
    PUBLIC_HEADERS
        CommandLineTool.h
        DefaultApplication.h
        FileOpenHandler.h
        QuitGuard.h
        RecentDocuments.h
    SOURCES
        CommandLineTool.cpp
        MacCommandLineTool_p.h
        MacCommandLineTool.mm
        DefaultApplication.cpp
        MacDefaultApplication_p.h
        MacDefaultApplication.mm
        FileOpenHandler.cpp
        MacServices_p.h
        MacServices.mm
        QuitGuard.cpp
        RecentDocuments.cpp
        MacRecentDocuments_p.h
        MacRecentDocuments.mm
    PUBLIC_LIBRARIES
        Qt6::Gui
    LIBRARIES
        "-framework AppKit"
        "-framework UniformTypeIdentifiers"
)
