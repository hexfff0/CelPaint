#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlExtensionPlugin>
#include <QQuickStyle>

#include "Core/AppController.h"
#include "Core/ColorSwapModel.h"
#include "Core/ImageSequence.h"
#include "Core/ImageSequenceProvider.h"
#include "Core/TimelineModel.h"

// Import static QML plugin
Q_IMPORT_QML_PLUGIN(CelPaint_UIPlugin)

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);

  // Set application metadata
  app.setApplicationName("CelPaint");
  app.setApplicationVersion("0.1");
  app.setOrganizationName("CelPaint");

  // Use Fusion style for consistent look
  QQuickStyle::setStyle("Fusion");

  // Create core objects
  ImageSequence sequence;
  AppController controller(&sequence);

  // Create QML engine
  QQmlApplicationEngine engine;

  // Register image provider (engine takes ownership)
  engine.addImageProvider("sequence", new ImageSequenceProvider(&sequence));

  // Set context properties
  engine.rootContext()->setContextProperty("app", &controller);

  // Load main QML from resource
  engine.load(QUrl(QStringLiteral("qrc:/CelPaint/UI/Main.qml")));

  if (engine.rootObjects().isEmpty()) {
    qCritical() << "Failed to load QML";
    return -1;
  }

  return app.exec();
}
