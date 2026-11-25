# rask_add_qml_module(<Name> URI <uri>
#     [SOURCES ...]          # every platform
#     [APPLE_SOURCES ...]    # macOS only (.mm compiled with ARC)
#     [OTHER_SOURCES ...]    # everywhere else (the no-op stubs)
#     [PUBLIC_HEADERS ...]   # installed to include/Rask/<Name>
#     [QML_FILES ...]
#     [RESOURCES ...]        # files in the library's resources, under qrc:/qt/qml/Rask/<Name>/
#     [LIBRARIES ...]        # linked privately
#     [APPLE_LIBRARIES ...]  # linked privately on macOS
#     [PUBLIC_LIBRARIES ...])
#
# Defines the shared library rask_<name> (file libRask<Name>.<major>.dylib,
# alias Rask::<Name>) backing the QML module <uri>, with hidden symbols, an
# export macro RASK_<NAME>_EXPORT in <Rask/<Name>/rask<name>_export.h>, and
# its install rules. Apps link the library; the QML plugin then stays
# optional and is never loaded (the qmldir is in the library's resources,
# under qrc:/qt/qml).
function(rask_add_qml_module name)
    cmake_parse_arguments(PARSE_ARGV 1 arg ""
        "URI"
        "SOURCES;APPLE_SOURCES;OTHER_SOURCES;PUBLIC_HEADERS;QML_FILES;RESOURCES;LIBRARIES;APPLE_LIBRARIES;PUBLIC_LIBRARIES")

    string(TOLOWER "${name}" lower)
    string(TOUPPER "${name}" upper)
    set(target rask_${lower})

    set(sources ${arg_SOURCES} ${arg_PUBLIC_HEADERS})
    if(APPLE)
        list(APPEND sources ${arg_APPLE_SOURCES})
        foreach(source IN LISTS arg_APPLE_SOURCES)
            if(source MATCHES "\\.mm$")
                set_source_files_properties(${source} PROPERTIES COMPILE_OPTIONS -fobjc-arc)
            endif()
        endforeach()
    else()
        list(APPEND sources ${arg_OTHER_SOURCES})
    endif()

    set(optional_args)
    if(arg_QML_FILES)
        list(APPEND optional_args QML_FILES ${arg_QML_FILES})
    endif()
    if(arg_RESOURCES)
        list(APPEND optional_args RESOURCES ${arg_RESOURCES})
    endif()

    qt_add_library(${target} SHARED)
    add_library(Rask::${name} ALIAS ${target})
    qt_add_qml_module(${target}
        URI ${arg_URI}
        VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        SOURCES ${sources}
        ${optional_args}
    )

    set(export_header "${PROJECT_BINARY_DIR}/src/Rask/${name}/rask${lower}_export.h")
    generate_export_header(${target}
        BASE_NAME RASK_${upper}
        EXPORT_FILE_NAME "${export_header}"
    )

    set_target_properties(${target} PROPERTIES
        OUTPUT_NAME Rask${name}
        EXPORT_NAME ${name}
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION_MAJOR}
        LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib"
        RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin"
        CXX_VISIBILITY_PRESET hidden
        OBJCXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN ON
    )

    # <Rask/<Name>/Header.h> for users; the bare header name for the
    # generated QML type registrations.
    target_include_directories(${target}
        PUBLIC
            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
            $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/src>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PRIVATE
            ${CMAKE_CURRENT_SOURCE_DIR}
    )

    # Flag padded class layouts in Debug (the member ordering rule in AGENTS.md).
    target_compile_options(${target} PRIVATE $<$<CONFIG:Debug>:-Wpadded>)

    target_link_libraries(${target}
        PUBLIC Qt6::Core Qt6::QmlIntegration ${arg_PUBLIC_LIBRARIES}
        PRIVATE ${arg_LIBRARIES}
    )
    if(APPLE AND arg_APPLE_LIBRARIES)
        target_link_libraries(${target} PRIVATE ${arg_APPLE_LIBRARIES})
    endif()

    install(TARGETS ${target}
        EXPORT RaskTargets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
    install(FILES ${arg_PUBLIC_HEADERS} "${export_header}"
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/Rask/${name}
    )
endfunction()
