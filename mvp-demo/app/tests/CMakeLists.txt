function(star_kylin_add_test target source)
  add_executable(${target} ${source})
  target_link_libraries(${target} PRIVATE star-kylin-core Qt${QT_VERSION_MAJOR}::Test)
  add_test(NAME ${target} COMMAND ${target})
endfunction()

star_kylin_add_test(test_manifest test_manifest.cpp)
star_kylin_add_test(test_tabs test_tabs.cpp)
star_kylin_add_test(test_auth test_auth.cpp)
star_kylin_add_test(test_native test_native.cpp)
star_kylin_add_test(test_urlpolicy test_urlpolicy.cpp)

add_executable(test_resources test_resources.cpp ../resources/resources.qrc)
target_link_libraries(test_resources PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)
add_test(NAME test_resources COMMAND test_resources)

add_executable(test_kline_data test_kline_data.cpp ../resources/resources.qrc)
target_link_libraries(test_kline_data PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)
add_test(NAME test_kline_data COMMAND test_kline_data)
