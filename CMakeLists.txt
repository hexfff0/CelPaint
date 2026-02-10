cmake_minimum_required(VERSION 3.16)

project(CelPaint VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
    add_compile_options(/Zc:__cplusplus /permissive-)
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 Widgets)

# Add subdirectories
add_subdirectory(Core)
add_subdirectory(UI)

# Main executable
qt_add_executable(CelPaint
    main.cpp
    app.rc
)

target_link_libraries(CelPaint PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Widgets
    Core
    CelPaintUIplugin
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
set_target_properties(CelPaint PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS CelPaint
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(WIN32)
    find_program(WINDEPLOYQT_EXECUTABLE windeployqt HINTS "C:/Qt/6.10.1/mingw_64/bin")
    if(WINDEPLOYQT_EXECUTABLE)
        add_custom_command(TARGET CelPaint POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:CelPaint>/deploy
            COMMAND ${WINDEPLOYQT_EXECUTABLE} --dir $<TARGET_FILE_DIR:CelPaint> --plugindir $<TARGET_FILE_DIR:CelPaint>/plugins --no-translations --compiler-runtime --no-opengl-sw $<TARGET_FILE:CelPaint>
            COMMENT "Running windeployqt..."
        )
    endif()
endif()
