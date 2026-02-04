qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_qml_module(CelPaintUI
    URI CelPaint.UI
    VERSION 1.0
    STATIC
    QML_FILES
        Main.qml
        Theme.js
        components/AppMenuBar.qml
        components/TimelineHeader.qml
        views/CanvasView.qml
        views/TimelineView.qml
        dialogs/ColorReplaceDialog.qml
        dialogs/GuideColorDialog.qml
        dialogs/AlphaCheckDialog.qml
        dialogs/ColorPicker.qml
    RESOURCES
        icon/Eye-Dropper--Streamline-Font-Awesome.svg
)

target_link_libraries(CelPaintUIplugin PRIVATE
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::QuickControls2
    Core
)

set_target_properties(CelPaintUI PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/CelPaint/UI"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/CelPaint/UI"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/CelPaint/UI"
)
