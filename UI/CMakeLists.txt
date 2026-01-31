qt_add_qml_module(CelPaintUI
    URI CelPaint.UI
    VERSION 1.0
    STATIC
    QML_FILES
        Main.qml
        CanvasView.qml
        ColorReplaceDialog.qml
        TimelineView.qml
        PhotoshopColorPicker.qml
        Theme.js
        GuideColorDialog.qml
)

target_link_libraries(CelPaintUIplugin PRIVATE
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::QuickControls2
    Core
)
