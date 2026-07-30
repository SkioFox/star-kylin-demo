add_executable(test_resources EXCLUDE_FROM_ALL test_resources.cpp ../resources/resources.qrc)
target_link_libraries(test_resources PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)

add_executable(test_manifest EXCLUDE_FROM_ALL test_manifest.cpp ../src/manifestservice.cpp)
target_include_directories(test_manifest PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_manifest PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)

add_executable(test_urlpolicy EXCLUDE_FROM_ALL test_urlpolicy.cpp ../src/urlpolicy.cpp)
target_include_directories(test_urlpolicy PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_urlpolicy PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)

add_executable(test_marketdata EXCLUDE_FROM_ALL test_marketdata.cpp ../src/marketdataservice.cpp ../src/markettablemodel.cpp ../resources/resources.qrc)
target_include_directories(test_marketdata PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_marketdata PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)

add_executable(test_native_launcher EXCLUDE_FROM_ALL test_native_launcher.cpp ../src/nativelauncher.cpp)
target_include_directories(test_native_launcher PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_native_launcher PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test)

add_executable(test_appcontroller EXCLUDE_FROM_ALL
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

add_executable(test_klinechart EXCLUDE_FROM_ALL test_klinechart.cpp ../src/klinechartitem.cpp ../resources/resources.qrc)
target_include_directories(test_klinechart PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_klinechart PRIVATE Qt${QT_VERSION_MAJOR}::Gui Qt${QT_VERSION_MAJOR}::Quick Qt${QT_VERSION_MAJOR}::Test)

add_executable(test_qml_load EXCLUDE_FROM_ALL test_qml_load.cpp ../src/klinechartitem.cpp ../resources/resources.qrc)
target_include_directories(test_qml_load PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_qml_load PRIVATE
  Qt${QT_VERSION_MAJOR}::Gui
  Qt${QT_VERSION_MAJOR}::Qml
  Qt${QT_VERSION_MAJOR}::Quick
  Qt${QT_VERSION_MAJOR}::QuickControls2
  Qt${QT_VERSION_MAJOR}::Test
  ${KYLIN_SKY_WEBENGINE_TARGET}
)

add_executable(test_all
  test_all.cpp
  ../src/appcontroller.cpp
  ../src/manifestservice.cpp
  ../src/mockauthservice.cpp
  ../src/modulelistmodel.cpp
  ../src/tablistmodel.cpp
  ../src/marketdataservice.cpp
  ../src/markettablemodel.cpp
  ../src/klinechartitem.cpp
  ../src/urlpolicy.cpp
  ../src/nativelauncher.cpp
  ../resources/resources.qrc
)
target_include_directories(test_all PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)
target_link_libraries(test_all PRIVATE
  Qt${QT_VERSION_MAJOR}::Gui
  Qt${QT_VERSION_MAJOR}::Qml
  Qt${QT_VERSION_MAJOR}::Quick
  Qt${QT_VERSION_MAJOR}::QuickControls2
  Qt${QT_VERSION_MAJOR}::Test
  ${KYLIN_SKY_WEBENGINE_TARGET}
)
add_test(NAME test_all COMMAND test_all)
set_tests_properties(test_all PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")
