# Helpers for apps that use the Rask libraries.
#
# rask_embed_libraries(<target> LIBRARIES Rask::Window ...)
#
# macOS: after each build, copies the given shared libraries into the app
# bundle's Contents/Frameworks under their install name
# (libRaskWindow.0.dylib), signs them ad hoc, and adds
# @executable_path/../Frameworks to the app's rpath, so the bundle runs on its
# own. Frameworks a library needs (Sparkle, for Rask::Updater) are embedded
# with it, keeping their own signature. Call it before the app's own
# POST_BUILD signing step: the bundle's signature must cover the embedded
# code.
function(rask_embed_libraries target)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "LIBRARIES")

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
        get_target_property(frameworks_needed ${real} RASK_EMBED_FRAMEWORKS)
        foreach(framework IN LISTS frameworks_needed)
            if(NOT framework)
                continue()
            endif()
            get_filename_component(framework_name "${framework}" NAME)
            # ditto keeps the framework's symlinks.
            add_custom_command(TARGET ${target} POST_BUILD
                COMMAND rm -rf "${frameworks}/${framework_name}"
                COMMAND ditto "${framework}" "${frameworks}/${framework_name}"
                COMMENT "Embedding ${framework_name}"
                VERBATIM
            )
        endforeach()
    endforeach()
endfunction()

# rask_sparkle_plist_keys(<out_var> FEED_URL <url> PUBLIC_KEY <key>)
#
# The Info.plist entries Rask::Updater reads, for the app's Info.plist.in
# (${<out_var>} inside its <dict>). Empty when either value is empty (Debug
# builds): the updater then stays off. Updates are on by default, without
# Sparkle's first-run question: checked daily, downloaded in the background
# and installed on quit.
function(rask_sparkle_plist_keys out_var)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "FEED_URL;PUBLIC_KEY" "")
    set(keys "")
    if(arg_FEED_URL AND arg_PUBLIC_KEY)
        string(CONCAT keys
            "\t<key>SUFeedURL</key>\n"
            "\t<string>${arg_FEED_URL}</string>\n"
            "\t<key>SUPublicEDKey</key>\n"
            "\t<string>${arg_PUBLIC_KEY}</string>\n"
            "\t<key>SUVerifyUpdateBeforeExtraction</key>\n"
            "\t<true/>\n"
            "\t<key>SUEnableAutomaticChecks</key>\n"
            "\t<true/>\n"
            "\t<key>SUAutomaticallyUpdate</key>\n"
            "\t<true/>\n"
        )
    endif()
    set(${out_var} "${keys}" PARENT_SCOPE)
endfunction()
