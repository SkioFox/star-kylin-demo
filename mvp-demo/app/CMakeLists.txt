cmake_minimum_required(VERSION 3.16)

project(star-kylin-demo VERSION 0.1.0 LANGUAGES CXX)

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
  set(STAR_KYLIN_WEBENGINE_CORE_TARGET Qt6::WebEngineCore)
  set(STAR_KYLIN_WEBENGINE_TARGET Qt6::WebEngineQuick)
else()
  find_package(Qt5 REQUIRED COMPONENTS WebEngine WebEngineCore)
  set(STAR_KYLIN_WEBENGINE_CORE_TARGET Qt5::WebEngineCore)
  set(STAR_KYLIN_WEBENGINE_TARGET Qt5::WebEngine)
endif()

add_library(star-kylin-core STATIC
  src/appcontroller.cpp
  src/appcontroller.h
  src/manifestservice.cpp
  src/manifestservice.h
  src/mockauthservice.cpp
  src/mockauthservice.h
  src/modulelistmodel.cpp
  src/modulelistmodel.h
  src/nativelauncher.cpp
  src/nativelauncher.h
  src/tablistmodel.cpp
  src/tablistmodel.h
  src/urlpolicy.cpp
  src/urlpolicy.h
  src/webprofilemanager.cpp
  src/webprofilemanager.h
)

target_include_directories(star-kylin-core PUBLIC src)
target_link_libraries(star-kylin-core PUBLIC
  Qt${QT_VERSION_MAJOR}::Core
  ${STAR_KYLIN_WEBENGINE_CORE_TARGET}
  ${STAR_KYLIN_WEBENGINE_TARGET}
)
target_compile_definitions(star-kylin-core PUBLIC QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII)

set(STAR_KYLIN_APP_SOURCES
  src/main.cpp
  resources/resources.qrc
)

if(QT_VERSION_MAJOR EQUAL 6)
  qt_add_executable(star-kylin-demo MANUAL_FINALIZATION ${STAR_KYLIN_APP_SOURCES})
else()
  add_executable(star-kylin-demo ${STAR_KYLIN_APP_SOURCES})
endif()

target_link_libraries(star-kylin-demo PRIVATE
  star-kylin-core
  Qt${QT_VERSION_MAJOR}::Gui
  Qt${QT_VERSION_MAJOR}::Qml
  Qt${QT_VERSION_MAJOR}::Quick
  Qt${QT_VERSION_MAJOR}::QuickControls2
  ${STAR_KYLIN_WEBENGINE_TARGET}
)

if(QT_VERSION_MAJOR EQUAL 6)
  qt_finalize_executable(star-kylin-demo)
endif()

if(BUILD_TESTING)
  add_subdirectory(tests)
endif()

install(TARGETS star-kylin-demo RUNTIME DESTINATION opt/star-kylin-demo/bin)
install(FILES packaging/star-kylin-demo.desktop DESTINATION usr/share/applications)
install(FILES packaging/star-kylin-demo.svg DESTINATION usr/share/icons/hicolor/scalable/apps)
install(FILES THIRD_PARTY_NOTICES.md DESTINATION usr/share/doc/star-kylin-demo)
install(FILES licenses/ECharts-LICENSE.txt licenses/Lucide-LICENSE.txt
  DESTINATION usr/share/doc/star-kylin-demo/licenses)

set(CPACK_GENERATOR DEB)
set(CPACK_PACKAGE_NAME star-kylin-demo)
set(CPACK_PACKAGE_VENDOR "Star Kylin Demo")
set(CPACK_PACKAGE_CONTACT "MVP Demo Maintainers")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Kylin desktop banking workbench MVP demo")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGING_INSTALL_PREFIX /)
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_DEBIAN_PACKAGE_SECTION office)
set(STAR_KYLIN_PACKAGE_RELEASE "1" CACHE STRING
  "Debian package release; increase for every distributable build")
set(CPACK_DEBIAN_PACKAGE_RELEASE "${STAR_KYLIN_PACKAGE_RELEASE}")

if(QT_VERSION_MAJOR EQUAL 5)
  set(STAR_KYLIN_DEFAULT_DEBIAN_RUNTIME_DEPENDS
    "qml-module-qtquick2, qml-module-qtquick-controls2, qml-module-qtquick-window2, qml-module-qtwebengine, libqt5svg5")
else()
  set(STAR_KYLIN_DEFAULT_DEBIAN_RUNTIME_DEPENDS "")
endif()
set(STAR_KYLIN_DEBIAN_RUNTIME_DEPENDS "${STAR_KYLIN_DEFAULT_DEBIAN_RUNTIME_DEPENDS}"
  CACHE STRING "Extra Debian runtime dependencies not discoverable through shared-library scanning")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "${STAR_KYLIN_DEBIAN_RUNTIME_DEPENDS}")

if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
  set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE arm64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
  set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)
endif()

include(CPack)
