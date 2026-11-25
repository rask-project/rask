# Helpers for apps that use the Rask libraries.
#
# rask_embed_libraries(<target> LIBRARIES Rask::Window ...)
#
# macOS: after each build, copies the given shared libraries into the app
# bundle's Contents/Frameworks under their install name
# (libRaskWindow.0.dylib), signs them ad hoc, and adds
# @executable_path/../Frameworks to the app's rpath, so the bundle runs on its
# own. Call it before the app's own POST_BUILD signing step: the bundle's
# signature must cover the embedded libraries. Elsewhere it does nothing (the
# build tree's rpath finds the libraries).
function(rask_embed_libraries target)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "LIBRARIES")
    if(NOT APPLE)
        return()
    endif()

    set_property(TARGET ${target} APPEND PROPERTY BUILD_RPATH "@executable_path/../Frameworks")
    set_property(TARGET ${target} APPEND PROPERTY INSTALL_RPATH "@executable_path/../Frameworks")

    set(frameworks "$<TARGET_BUNDLE_CONTENT_DIR:${target}>/Frameworks")
    foreach(library IN LISTS arg_LIBRARIES)
        get_target_property(real ${library} ALIASED_TARGET)
        if(NOT real)
            set(real ${library})
        endif()
        add_dependencies(${target} ${real})
        set(embedded "${frameworks}/$<TARGET_SONAME_FILE_NAME:${real}>")
        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory "${frameworks}"
            COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:${real}>" "${embedded}"
            COMMAND codesign --force --sign - "${embedded}"
            COMMENT "Embedding ${library}"
            VERBATIM
        )
    endforeach()
endfunction()
