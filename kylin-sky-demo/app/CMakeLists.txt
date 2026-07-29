cmake_minimum_required(VERSION 3.16)

project(kylin-sky-demo VERSION 0.1.0 LANGUAGES CXX)

include(CTest)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Test)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Test)

if(QT_VERSION_MAJOR EQUAL 6)
  find_package(Qt6 REQUIRED COMPONENTS WebEngineCore WebEngineQuick)
  set(KYLIN_SKY_WEBENGINE_TARGET Qt6::WebEngineQuick)
else()
  find_package(Qt5 REQUIRED COMPONENTS WebEngine WebEngineCore)
  set(KYLIN_SKY_WEBENGINE_TARGET Qt5::WebEngine)
endif()

set(KYLIN_SKY_APP_SOURCES
  src/main.cpp
  src/appcontroller.cpp
  src/appcontroller.h
  src/manifestservice.cpp
  src/manifestservice.h
  src/mockauthservice.cpp
  src/mockauthservice.h
  src/modulelistmodel.cpp
  src/modulelistmodel.h
  src/tablistmodel.cpp
  src/tablistmodel.h
  src/markettablemodel.cpp
  src/markettablemodel.h
  src/marketdataservice.cpp
  src/marketdataservice.h
  src/klinechartitem.cpp
  src/klinechartitem.h
  src/urlpolicy.cpp
  src/urlpolicy.h
  src/webprofilemanager.cpp
  src/webprofilemanager.h
  src/nativelauncher.cpp
  src/nativelauncher.h
  resources/resources.qrc
)

if(QT_VERSION_MAJOR EQUAL 6)
  qt_add_executable(kylin-sky-demo MANUAL_FINALIZATION ${KYLIN_SKY_APP_SOURCES})
else()
  add_executable(kylin-sky-demo ${KYLIN_SKY_APP_SOURCES})
endif()

target_link_libraries(kylin-sky-demo PRIVATE
  Qt${QT_VERSION_MAJOR}::Gui
  Qt${QT_VERSION_MAJOR}::Qml
  Qt${QT_VERSION_MAJOR}::Quick
  Qt${QT_VERSION_MAJOR}::QuickControls2
  ${KYLIN_SKY_WEBENGINE_TARGET}
)
target_compile_definitions(kylin-sky-demo PRIVATE QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII)

if(QT_VERSION_MAJOR EQUAL 6)
  qt_finalize_executable(kylin-sky-demo)
endif()

if(BUILD_TESTING)
  add_subdirectory(tests)
endif()

install(TARGETS kylin-sky-demo RUNTIME DESTINATION opt/kylin-sky-demo/bin)
install(FILES packaging/kylin-sky-demo.desktop DESTINATION usr/share/applications)
install(FILES packaging/kylin-sky-demo.svg DESTINATION usr/share/icons/hicolor/scalable/apps)
install(FILES THIRD_PARTY_NOTICES.md DESTINATION usr/share/doc/kylin-sky-demo)

set(CPACK_GENERATOR DEB)
set(CPACK_PACKAGE_NAME kylin-sky-demo)
set(CPACK_PACKAGE_VENDOR "Kylin Sky Demo")
set(CPACK_PACKAGE_CONTACT "Kylin Sky Demo Maintainers")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Kylin desktop banking workbench demo")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(KYLIN_SKY_PACKAGE_RELEASE "1" CACHE STRING "Debian package release")
set(CPACK_DEBIAN_PACKAGE_RELEASE "${KYLIN_SKY_PACKAGE_RELEASE}")
set(CPACK_PACKAGING_INSTALL_PREFIX /)
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_DEBIAN_PACKAGE_SECTION office)

# QML imports are loaded at runtime and are not discoverable by shlibdeps.
if(QT_VERSION_MAJOR EQUAL 5)
  set(KYLIN_SKY_DEFAULT_DEBIAN_RUNTIME_DEPENDS
    "qml-module-qtquick2, qml-module-qtquick-controls2, qml-module-qtquick-window2, qml-module-qtwebengine, libqt5svg5")
else()
  set(KYLIN_SKY_DEFAULT_DEBIAN_RUNTIME_DEPENDS "")
endif()
set(KYLIN_SKY_DEBIAN_RUNTIME_DEPENDS "${KYLIN_SKY_DEFAULT_DEBIAN_RUNTIME_DEPENDS}"
  CACHE STRING "Extra Debian runtime dependencies not discoverable through shared-library scanning")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "${KYLIN_SKY_DEBIAN_RUNTIME_DEPENDS}")

if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
  set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE arm64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
  set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)
endif()

include(CPack)
