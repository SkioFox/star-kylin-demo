add_executable(test_resources test_resources.cpp ../resources/resources.qrc)
target_link_libraries(test_resources PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)
add_test(NAME test_resources COMMAND test_resources)

add_executable(test_manifest test_manifest.cpp ../src/manifestservice.cpp)
target_include_directories(test_manifest PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_manifest PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)
add_test(NAME test_manifest COMMAND test_manifest)

add_executable(test_urlpolicy test_urlpolicy.cpp ../src/urlpolicy.cpp)
target_include_directories(test_urlpolicy PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_urlpolicy PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)
add_test(NAME test_urlpolicy COMMAND test_urlpolicy)

add_executable(test_marketdata test_marketdata.cpp ../src/marketdataservice.cpp ../src/markettablemodel.cpp ../resources/resources.qrc)
target_include_directories(test_marketdata PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_marketdata PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)
add_test(NAME test_marketdata COMMAND test_marketdata)

add_executable(test_native_launcher test_native_launcher.cpp ../src/nativelauncher.cpp)
target_include_directories(test_native_launcher PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_native_launcher PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)
add_test(NAME test_native_launcher COMMAND test_native_launcher)

add_executable(test_appcontroller
  test_appcontroller.cpp
  ../src/appcontroller.cpp
  ../src/manifestservice.cpp
  ../src/mockauthservice.cpp
  ../src/modulelistmodel.cpp
  ../src/tablistmodel.cpp
  ../src/nativelauncher.cpp
  ../resources/resources.qrc
)
target_include_directories(test_appcontroller PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_appcontroller PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)
add_test(NAME test_appcontroller COMMAND test_appcontroller)

add_executable(test_klinechart test_klinechart.cpp ../src/klinechartitem.cpp ../resources/resources.qrc)
target_include_directories(test_klinechart PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_klinechart PRIVATE Qt${QT_VERSION_MAJOR}::Gui Qt${QT_VERSION_MAJOR}::Quick Qt${QT_VERSION_MAJOR}::Test)
add_test(NAME test_klinechart COMMAND test_klinechart)
set_tests_properties(test_klinechart PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

add_executable(test_qml_load test_qml_load.cpp ../src/klinechartitem.cpp ../resources/resources.qrc)
target_include_directories(test_qml_load PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_qml_load PRIVATE
  Qt${QT_VERSION_MAJOR}::Gui
  Qt${QT_VERSION_MAJOR}::Qml
  Qt${QT_VERSION_MAJOR}::Quick
  Qt${QT_VERSION_MAJOR}::QuickControls2
  Qt${QT_VERSION_MAJOR}::Test
)
add_test(NAME test_qml_load COMMAND test_qml_load)
set_tests_properties(test_qml_load PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")
