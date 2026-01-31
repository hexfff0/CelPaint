#include "ImageSequence.h"
#include <QDebug>
#include <QFileInfo>
#include <QtGlobal>

ImageSequence::ImageSequence(QObject *parent)
    : QObject(parent), m_currentIndex(-1) {}

void ImageSequence::loadSequence(const QStringList &filePaths) {
  m_frames.clear();
  m_currentIndex = -1;

  for (const QString &path : filePaths) {
    QImage img(path);
    if (!img.isNull()) {
      // Convert to ARGB32 for consistent pixel manipulation
      if (img.format() != QImage::Format_ARGB32) {
        img = img.convertToFormat(QImage::Format_ARGB32);
      }
      m_frames.append({path, img});
    }
  }

  emit countChanged();

  if (!m_frames.isEmpty()) {
    m_currentIndex = 0;
    emit sequenceLoaded();
    emit currentIndexChanged(m_currentIndex);
    emit currentImageChanged(m_frames[0].image);
  }
}

void ImageSequence::saveSequence(const QString &outputDir,
                                 const QString &format) {
  QDir dir(outputDir);
  if (!dir.exists()) {
    dir.mkpath(".");
  }

  for (int i = 0; i < m_frames.size(); ++i) {
    QString fileName = QFileInfo(m_frames[i].originalPath).fileName();
    QString newPath = dir.filePath(fileName);
    m_frames[i].image.save(newPath, format.toLatin1().constData());
  }
}

QImage ImageSequence::currentImage() const {
  if (m_currentIndex >= 0 && m_currentIndex < m_frames.size()) {
    return m_frames[m_currentIndex].image;
  }
  return QImage();
}

int ImageSequence::currentIndex() const { return m_currentIndex; }

int ImageSequence::count() const { return m_frames.size(); }

QString ImageSequence::currentFilePath() const {
  if (m_currentIndex >= 0 && m_currentIndex < m_frames.size()) {
    return m_frames[m_currentIndex].originalPath;
  }
  return QString();
}

QImage ImageSequence::imageAt(int index) const {
  if (index >= 0 && index < m_frames.size()) {
    return m_frames[index].image;
  }
  return QImage();
}

void ImageSequence::setCurrentIndex(int index) {
  if (index >= 0 && index < m_frames.size() && index != m_currentIndex) {
    m_currentIndex = index;
    emit currentIndexChanged(m_currentIndex);
    emit currentImageChanged(m_frames[m_currentIndex].image);
  }
}

void ImageSequence::replaceColorsInCurrentFrame(const QList<ColorSwap> &swaps) {
  if (m_currentIndex < 0 || m_currentIndex >= m_frames.size())
    return;

  replaceColorsInImage(m_frames[m_currentIndex].image, swaps);
  emit imageModified(m_currentIndex, m_frames[m_currentIndex].image);
  emit currentImageChanged(m_frames[m_currentIndex].image);
}

void ImageSequence::replaceColorsInAllFrames(const QList<ColorSwap> &swaps) {
  for (int i = 0; i < m_frames.size(); ++i) {
    replaceColorsInImage(m_frames[i].image, swaps);
    emit imageModified(i, m_frames[i].image);
  }

  if (m_currentIndex >= 0) {
    emit currentImageChanged(m_frames[m_currentIndex].image);
  }
}

void ImageSequence::replaceColorsInImage(QImage &img,
                                         const QList<ColorSwap> &swaps) {
  // Pre-filter enabled swaps
  QList<ColorSwap> activeSwaps;
  for (const auto &s : swaps) {
    if (s.enabled)
      activeSwaps.append(s);
  }

  if (activeSwaps.isEmpty())
    return;

  int w = img.width();
  int h = img.height();

  for (int y = 0; y < h; ++y) {
    QRgb *line = reinterpret_cast<QRgb *>(img.scanLine(y));
    for (int x = 0; x < w; ++x) {
      QRgb current = line[x];

      for (const auto &swap : activeSwaps) {
        bool match = false;
        if (swap.tolerance == 0) {
          if (current == swap.source.rgba()) {
            match = true;
          }
        } else {
          int r = qRed(current);
          int g = qGreen(current);
          int b = qBlue(current);
          int a = qAlpha(current);

          int sr = swap.source.red();
          int sg = swap.source.green();
          int sb = swap.source.blue();
          int sa = swap.source.alpha();

          if (abs(r - sr) <= swap.tolerance && abs(g - sg) <= swap.tolerance &&
              abs(b - sb) <= swap.tolerance && abs(a - sa) <= swap.tolerance) {
            match = true;
          }
        }

        if (match) {
          line[x] = swap.dest.rgba();
          break;
        }
      }
    }
  }
}
