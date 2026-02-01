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
        dialogs/PhotoshopColorPicker.qml
)

target_link_libraries(CelPaintUIplugin PRIVATE
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::QuickControls2
    Core
)
