#ifndef MAIN_H
#define MAIN_H

#include <QLabel>
#include <QListWidget>
#include <QMainWindow>
#include <QScrollArea>

class ImageSequence;
class ColorReplaceDialog;

QT_BEGIN_NAMESPACE
namespace Ui {
class Main;
}
QT_END_NAMESPACE

class Main : public QMainWindow {
  Q_OBJECT

public:
  Main(QWidget *parent = nullptr);
  ~Main();

protected:
  // Event filter for color picking from the image
  bool eventFilter(QObject *watched, QEvent *event) override;
  // Zoom support
  void wheelEvent(QWheelEvent *event) override;
  // Pan support
  void keyPressEvent(QKeyEvent *event) override;
  void keyReleaseEvent(QKeyEvent *event) override;
  void mousePressEvent(QMouseEvent *event) override;
  void mouseMoveEvent(QMouseEvent *event) override;
  void mouseReleaseEvent(QMouseEvent *event) override;

private slots:
  void onActionOpenTriggered();
  void onActionExportTriggered();
  void onActionColorReplaceTriggered();

  void onSequenceLoaded();
  void onCurrentImageChanged(const QImage &image);
  void onTimelineItemClicked(QListWidgetItem *item);

  void applyColorReplacement(bool allFrames);

private:
  Ui::Main *ui;

  ImageSequence *m_sequence;
  ColorReplaceDialog *m_colorReplaceDlg;

  QScrollArea *m_scrollArea;
  QLabel *m_imageLabel;
  QListWidget *m_timelineList;

  // Zoom
  double m_scaleFactor;
  void zoomIn();
  void zoomOut();
  void updateImageDisplay();

  // Pan
  bool m_isPanning;
  bool m_spaceHeld;
  QPoint m_lastPanPos;

  void setupUiProgrammatically();
  void updateTimeline();
};

#endif // MAIN_H
