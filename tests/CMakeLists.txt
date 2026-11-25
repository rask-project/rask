find_package(Qt6 REQUIRED COMPONENTS Test)

function(rask_add_test name)
    qt_add_executable(${name} ${name}.h ${name}.cpp)
    target_link_libraries(${name} PRIVATE Qt6::Test ${ARGN})
    add_test(NAME ${name} COMMAND ${name})
    set_tests_properties(${name} PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")
endfunction()

rask_add_test(tst_appearance Rask::Platform)
rask_add_test(tst_nativewindow Rask::Window)
