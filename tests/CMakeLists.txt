# Using QWindowSystemInterface is deliberate (see tst_application).
set(QT_NO_PRIVATE_MODULE_WARNING ON)
find_package(Qt6 REQUIRED COMPONENTS Test GuiPrivate)

function(rask_add_test name)
    qt_add_executable(${name} ${name}.h ${name}.cpp)
    target_link_libraries(${name} PRIVATE Qt6::Test ${ARGN})
    add_test(NAME ${name} COMMAND ${name})
    set_tests_properties(${name} PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")
endfunction()

rask_add_test(tst_appearance Rask::Platform)
rask_add_test(tst_systemcolors Rask::Platform)
rask_add_test(tst_nativewindow Rask::Window)

rask_add_test(tst_dialogs Rask::Dialogs)
rask_add_test(tst_updater Rask::Updater)
rask_add_test(tst_glasseffect Rask::Window)
rask_add_test(tst_controls Rask::Controls Qt6::Qml)
# GuiPrivate: QWindowSystemInterface simulates the system's quit request.
rask_add_test(tst_application Rask::Application Qt6::GuiPrivate)
