#include "AppController.h"
#include "ColorSwapModel.h"
#include "ImageSequence.h"
#include "TimelineModel.h"
#include <QFileInfo>
#include <QUrl>
#include <algorithm>

AppController::AppController(ImageSequence *sequence, QObject *parent)
    : QObject(parent), m_sequence(sequence),
      m_colorSwapModel(new ColorSwapModel(this)),
      m_timelineModel(new TimelineModel(sequence, this)),
      m_statusMessage("Ready"), m_zoomLevel(1.0) {
  connect(m_sequence, &ImageSequence::sequenceLoaded, this,
          &AppController::onSequenceLoaded);
  connect(m_sequence, &ImageSequence::currentImageChanged, this,
          &AppController::onCurrentImageChanged);
  connect(m_sequence, &ImageSequence::currentIndexChanged, this,
          [this]() { emit currentIndexChanged(); });
  connect(m_sequence, &ImageSequence::countChanged, this, [this]() {
    emit frameCountChanged();
    emit titleChanged();
  });
  connect(m_sequence, &ImageSequence::imageModified, this,
          &AppController::onImageModified);
}

QString AppController::currentTitle() const {
  if (m_sequence->count() == 0) {
    return "CelPaint";
  }
  QString filePath = m_sequence->currentFilePath();
  QString fileName = QFileInfo(filePath).fileName();
  return QString("CelPaint - %1 [%2/%3]")
      .arg(fileName)
      .arg(m_sequence->currentIndex() + 1)
      .arg(m_sequence->count());
}

QString AppController::statusMessage() const { return m_statusMessage; }

ColorSwapModel *AppController::colorSwapModel() const {
  return m_colorSwapModel;
}

TimelineModel *AppController::timelineModel() const { return m_timelineModel; }

int AppController::currentIndex() const { return m_sequence->currentIndex(); }

int AppController::frameCount() const { return m_sequence->count(); }

double AppController::zoomLevel() const { return m_zoomLevel; }

void AppController::setCurrentIndex(int index) {
  m_sequence->setCurrentIndex(index);
}

void AppController::setZoomLevel(double level) {
  if (qFuzzyCompare(m_zoomLevel, level))
    return;
  m_zoomLevel = level;
  emit zoomLevelChanged();
  setStatusMessage(QString("Zoom: %1%").arg(int(m_zoomLevel * 100)));
}

void AppController::openSequence(const QList<QUrl> &urls) {
  QStringList paths;
  for (const QUrl &url : urls) {
    paths.append(url.toLocalFile());
  }

  // Sort paths alphabetically
  std::sort(paths.begin(), paths.end());

  m_sequence->loadSequence(paths);
}

bool AppController::saveSequence(const QUrl &folderUrl) {
  if (m_sequence->count() == 0)
    return false;

  QString folderPath = folderUrl.toLocalFile();
  m_sequence->saveSequence(folderPath);
  setStatusMessage("Sequence exported successfully.");
  return true;
}

void AppController::pickColorAt(int x, int y) {
  if (m_sequence) {
    if (x >= 0 && x < m_sequence->currentImage().width() && y >= 0 &&
        y < m_sequence->currentImage().height()) {
      QColor color = m_sequence->currentImage().pixelColor(x, y);

      // Add to source colors in model if it doesn't represent a known swap
      // For now, let's just emit a signal or helper.
      // But actually, the requirements are to "pick color".
      // Let's modify logic: if generic pick, maybe invoke a callback?
      // Existing logic was just logging or unused.
      // Let's add it to the model as a new source color candidate.
      m_colorSwapModel->addSourceColor(color);
    }
  }
}

QColor AppController::pickScreenColor(int x, int y) {
  QScreen *screen = QGuiApplication::screenAt(QPoint(x, y));
  if (!screen)
    return QColor();

  // Grab 1x1 pixel
  QPixmap pixmap = screen->grabWindow(0, x, y, 1, 1);
  if (pixmap.isNull())
    return QColor();

  return pixmap.toImage().pixelColor(0, 0);
}

void AppController::applyColorReplacement(bool allFrames) {
  QList<ColorSwap> swaps = m_colorSwapModel->getSwaps();

  if (allFrames) {
    m_sequence->replaceColorsInAllFrames(swaps);
    setStatusMessage("Replaced colors in all frames.");
  } else {
    m_sequence->replaceColorsInCurrentFrame(swaps);
    setStatusMessage("Replaced colors in current frame.");
  }

  emit requestImageRefresh();
}

void AppController::addCustomColor(const QColor &color) {
  if (!m_customColors.contains(color)) {
    // Limit size? 16 colors for now (2 rows of 8)
    if (m_customColors.size() >= 16) {
      m_customColors.removeFirst();
    }
    m_customColors.append(color);
    emit customColorsChanged();
  }
}

QList<QColor> AppController::customColors() const { return m_customColors; }

void AppController::onSequenceLoaded() {
  setStatusMessage(QString("Loaded %1 frames").arg(m_sequence->count()));
  m_zoomLevel = 1.0;
  emit zoomLevelChanged();
  emit titleChanged();
  emit requestImageRefresh();
}

void AppController::onCurrentImageChanged() {
  emit titleChanged();
  emit requestImageRefresh();
}

void AppController::onImageModified(int index) {
  Q_UNUSED(index);
  emit requestImageRefresh();
}

void AppController::setStatusMessage(const QString &msg) {
  if (m_statusMessage != msg) {
    m_statusMessage = msg;
    emit statusMessageChanged();
  }
}
