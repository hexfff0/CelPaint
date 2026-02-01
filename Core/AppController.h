#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include "ColorSwapModel.h"
#include "GuideCheckModel.h"
#include "TimelineModel.h"
#include <QGuiApplication>
#include <QList>
#include <QObject>
#include <QScreen>
#include <QUrl>
#include <QUndoStack>
#include <QtGui/QColor>

class ImageSequence;

class AppController : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString currentTitle READ currentTitle NOTIFY titleChanged)
  Q_PROPERTY(
      QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
  Q_PROPERTY(ColorSwapModel *colorSwapModel READ colorSwapModel CONSTANT)
  Q_PROPERTY(GuideCheckModel *guideCheckModel READ guideCheckModel CONSTANT)
  Q_PROPERTY(TimelineModel *timelineModel READ timelineModel CONSTANT)
  Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY
                 currentIndexChanged)
  Q_PROPERTY(int frameCount READ frameCount NOTIFY frameCountChanged)
  Q_PROPERTY(double zoomLevel READ zoomLevel WRITE setZoomLevel NOTIFY
                 zoomLevelChanged)
  Q_PROPERTY(
      QList<QColor> customColors READ customColors NOTIFY customColorsChanged)

public:
  explicit AppController(ImageSequence *sequence, QObject *parent = nullptr);

  // Property getters
  QString currentTitle() const;
  QString statusMessage() const;
  ColorSwapModel *colorSwapModel() const;
  GuideCheckModel *guideCheckModel() const;
  TimelineModel *timelineModel() const;
  int currentIndex() const;
  int frameCount() const;
  double zoomLevel() const;

  // Property setters (Q_INVOKABLE for direct QML calls)
  Q_INVOKABLE void setCurrentIndex(int index);
  Q_INVOKABLE void setZoomLevel(double level);
  
  Q_INVOKABLE void quitApp();

  // QML invokable methods
  Q_INVOKABLE void openSequence(const QList<QUrl> &urls);
  Q_INVOKABLE bool saveSequence(const QUrl &folderUrl);
  Q_INVOKABLE void pickColorAt(int x, int y);
  Q_INVOKABLE QColor pickScreenColor(int x, int y);
  Q_INVOKABLE void applyColorReplacement(bool allFrames);

  // Guide Color Feature
  Q_INVOKABLE void applyGuideCheck(bool allFrames, int radius, int thickness);

  // Alpha Check Feature
  Q_INVOKABLE void applyAlphaCheck(bool allFrames, const QColor &color,
                                   int size, int thickness);

  Q_INVOKABLE void addCustomColor(const QColor &color);
  QList<QColor> customColors() const;

  // Undo/Redo
  Q_INVOKABLE void undo();
  Q_INVOKABLE void redo();
  Q_INVOKABLE bool canUndo() const;
  Q_INVOKABLE bool canRedo() const;

signals:
  void titleChanged();
  void statusMessageChanged();
  void customColorsChanged();
  void currentIndexChanged();
  void frameCountChanged();
  void zoomLevelChanged();
  void requestImageRefresh();

private slots:
  void onSequenceLoaded();
  void onCurrentImageChanged();
  void onImageModified(int index);

private:
  void setStatusMessage(const QString &msg);

  ImageSequence *m_sequence;
  ColorSwapModel *m_colorSwapModel;
  GuideCheckModel *m_guideCheckModel;
  TimelineModel *m_timelineModel;
  QString m_statusMessage;
  double m_zoomLevel = 1.0;
  QList<QColor> m_customColors;
  QUndoStack *m_undoStack;
};

#endif // APPCONTROLLER_H
