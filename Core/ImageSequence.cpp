#include "ImageSequence.h"
#include <QDataStream>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QPainter>
#include <QPen>
#include <QPoint>
#include <QVector>
#include <QtGlobal>
#include <cmath>
#include <cstdlib>
#include <queue>
#include <vector>

ImageSequence::ImageSequence(QObject *parent)
    : QObject(parent), m_currentIndex(-1) {}

// Minimal TGA Loader (Uncompressed & RLE TrueColor)
static QImage loadTGA(const QString &filePath) {
  QFile file(filePath);
  if (!file.open(QIODevice::ReadOnly))
    return QImage();

  QDataStream in(&file);
  in.setByteOrder(QDataStream::LittleEndian);

  quint8 idLength, colorMapType, imageType;
  quint8 temp8;
  quint16 temp16;
  quint16 width, height;
  quint8 pixelDepth, descriptor;

  in >> idLength >> colorMapType >> imageType;
  in.skipRawData(5); // Skip color map spec
  in.skipRawData(4); // Skip x, y origin
  in >> width >> height >> pixelDepth >> descriptor;

  // Only support TrueColor (2) and RLE TrueColor (10)
  // Supports 24 and 32 bit depth
  if ((imageType != 2 && imageType != 10) ||
      (pixelDepth != 24 && pixelDepth != 32)) {
    return QImage();
  }

  in.skipRawData(idLength); // Skip ID field
  // Skip color map if present (shouldn't be for type 2/10 usually, but logic
  // implies unsupp if colorMapType=1)

  QImage image(width, height, QImage::Format_ARGB32);
  image.fill(Qt::transparent);

  bool isRLE = (imageType == 10);
  int bytesPerPixel = pixelDepth / 8;
  quint64 totalPixels = width * height;
  quint64 currentPixel = 0;

  while (currentPixel < totalPixels && !in.atEnd()) {
    quint8 chunkHeader;
    if (isRLE) {
      in >> chunkHeader;
    } else {
      chunkHeader = 127; // Treat as raw packet of max length 128 (0-127)
    }

    bool isRaw = !isRLE || (chunkHeader < 128);
    int chunkCount = (chunkHeader & 0x7F) + 1;

    if (isRaw) { // Raw packet
      for (int i = 0; i < chunkCount; ++i) {
        if (currentPixel >= totalPixels)
          break;

        quint8 b, g, r, a = 255;
        in >> b >> g >> r;
        if (bytesPerPixel == 4)
          in >> a;

        int x = currentPixel % width;
        int y = currentPixel / width;
        if (descriptor & 0x20)
          y = y;
        else
          y = height - 1 - y; // TGA is bottom-up unless bit 5 set

        image.setPixelColor(x, y, QColor(r, g, b, a));
        currentPixel++;
      }
    } else { // RLE packet (Run-length)
      quint8 b, g, r, a = 255;
      in >> b >> g >> r;
      if (bytesPerPixel == 4)
        in >> a;
      QColor color(r, g, b, a);

      for (int i = 0; i < chunkCount; ++i) {
        if (currentPixel >= totalPixels)
          break;

        int x = currentPixel % width;
        int y = currentPixel / width;
        if (descriptor & 0x20)
          y = y;
        else
          y = height - 1 - y;

        image.setPixelColor(x, y, color);
        currentPixel++;
      }
    }
  }

  return image;
}

void ImageSequence::loadSequence(const QStringList &filePaths) {
  m_frames.clear();
  m_currentIndex = -1;

  for (const QString &path : filePaths) {
    QImage img(path);
    if (img.isNull()) {
      // Try manual TGA loader
      if (path.endsWith(".tga", Qt::CaseInsensitive)) {
        img = loadTGA(path);
      }
    }

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

// Helper for color matching with tolerance
static bool colorsMatch(const QColor &c1, const QColor &c2, int tolerance) {
  if (tolerance <= 0)
    return c1 == c2;

  int r1 = c1.red(), g1 = c1.green(), b1 = c1.blue(), a1 = c1.alpha();
  int r2 = c2.red(), g2 = c2.green(), b2 = c2.blue(), a2 = c2.alpha();

  return qAbs(r1 - r2) <= tolerance && qAbs(g1 - g2) <= tolerance &&
         qAbs(b1 - b2) <= tolerance && qAbs(a1 - a2) <= tolerance;
}

// Helper to process a single image
static bool processGuideCheckOnImage(QImage &img,
                                     const QList<GuideColorParams> &params) {
  if (params.isEmpty())
    return false;

  QImage resultImg = img.copy();
  QPainter painter(&resultImg);
  painter.setRenderHint(QPainter::Antialiasing);
  bool modified = false;

  int w = img.width();
  int h = img.height();
  QVector<bool> visited(w * h, false);
  QList<QPoint> queue;

  for (const auto &p : params) {
    if (!p.enabled)
      continue;

    std::fill(visited.begin(), visited.end(),
              false); // Reset visited for each param?
    // Logic check: if visited is shared across params, blobs might interfere
    // if they overlap? Original code: `QVector<bool> visited(w * h, false);`
    // calculated once PER IMAGE? Wait. Original code declared `visited`
    // INSIDE the params loop: `for (const auto &p : params) { ...
    // QVector<bool> visited ... }` So yes, it resets for each color check. My
    // static helper should follow that.
  }

  // Actually, let's copy the code logic exactly.
  for (const auto &p : params) {
    if (!p.enabled)
      continue;

    int w = img.width();
    int h = img.height();
    QVector<bool> visited(w * h, false);
    QList<QPoint> queue;

    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        if (visited[y * w + x])
          continue;

        if (colorsMatch(img.pixelColor(x, y), p.sourceColor, p.tolerance)) {
          // BFS
          long long sumX = 0, sumY = 0;
          int count = 0;

          queue.clear();
          queue.append(QPoint(x, y));
          visited[y * w + x] = true;

          while (!queue.isEmpty()) {
            QPoint pt = queue.takeFirst();
            sumX += pt.x();
            sumY += pt.y();
            count++;

            const int dx[] = {1, -1, 0, 0};
            const int dy[] = {0, 0, 1, -1};

            for (int k = 0; k < 4; ++k) {
              int nx = pt.x() + dx[k];
              int ny = pt.y() + dy[k];

              if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                if (!visited[ny * w + nx] &&
                    colorsMatch(img.pixelColor(nx, ny), p.sourceColor,
                                p.tolerance)) {
                  visited[ny * w + nx] = true;
                  queue.append(QPoint(nx, ny));
                }
              }
            }
          }

          if (count > 0) {
            int centerX = sumX / count;
            int centerY = sumY / count;
            QPen pen(p.selectionColor);
            pen.setWidth(p.thickness);
            painter.setPen(pen);
            painter.setBrush(Qt::NoBrush);
            painter.drawEllipse(QPoint(centerX, centerY), p.radius, p.radius);
            modified = true;
          }
        }
      }
    }
  }
  painter.end();

  if (modified) {
    img = resultImg;
  }
  return modified;
}

void ImageSequence::applyGuideCheckToAllFrames(
    const QList<GuideColorParams> &params) {
  if (params.isEmpty())
    return;

  for (int i = 0; i < m_frames.size(); ++i) {
    if (processGuideCheckOnImage(m_frames[i].image, params)) {
      emit imageModified(i, m_frames[i].image);
    }
  }

  if (m_currentIndex >= 0) {
    emit currentImageChanged(m_frames[m_currentIndex].image);
  }
}

void ImageSequence::applyGuideCheckToCurrentFrame(
    const QList<GuideColorParams> &params) {
  if (params.isEmpty() || m_currentIndex < 0 ||
      m_currentIndex >= m_frames.size())
    return;

  if (processGuideCheckOnImage(m_frames[m_currentIndex].image, params)) {
    emit imageModified(m_currentIndex, m_frames[m_currentIndex].image);
    emit currentImageChanged(m_frames[m_currentIndex].image);
  }
}

// Helper for Alpha Check
static bool processAlphaCheckOnImage(QImage &img,
                                     const AlphaCheckParams &params) {
  if (img.isNull())
    return false;

  int w = img.width();
  int h = img.height();
  QVector<bool> visited(w * h, false);
  QList<QPoint> queue;
  bool modified = false;

  QPainter painter(&img);
  QPen pen(params.crossColor);
  pen.setWidth(params.thickness);
  painter.setPen(pen);

  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      if (visited[y * w + x])
        continue;

      // Check if pixel is fully transparent
      if (img.pixelColor(x, y).alpha() == 0) {
        // Found a new alpha region
        visited[y * w + x] = true;
        queue.clear();
        queue.append(QPoint(x, y));

        long long sumX = 0;
        long long sumY = 0;
        int count = 0;

        while (!queue.isEmpty()) {
          QPoint p = queue.takeFirst();
          sumX += p.x();
          sumY += p.y();
          count++;

          // Neighbors (4-connected)
          const int dx[] = {0, 0, 1, -1};
          const int dy[] = {1, -1, 0, 0};

          for (int i = 0; i < 4; ++i) {
            int nx = p.x() + dx[i];
            int ny = p.y() + dy[i];

            if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
              if (!visited[ny * w + nx] &&
                  img.pixelColor(nx, ny).alpha() == 0) {
                visited[ny * w + nx] = true;
                queue.append(QPoint(nx, ny));
              }
            }
          }
        }

        // Draw crosshair at center of mass
        if (count > 0) {
          int centerX = sumX / count;
          int centerY = sumY / count;
          int halfSize = params.crossSize / 2;

          painter.drawLine(centerX - halfSize, centerY - halfSize,
                           centerX + halfSize, centerY + halfSize);
          painter.drawLine(centerX - halfSize, centerY + halfSize,
                           centerX + halfSize, centerY - halfSize);
          modified = true;
        }
      }
    }
  }

  painter.end();
  return modified;
}

void ImageSequence::applyAlphaCheckToAllFrames(const AlphaCheckParams &params) {
  for (int i = 0; i < m_frames.size(); ++i) {
    if (processAlphaCheckOnImage(m_frames[i].image, params)) {
      emit imageModified(i, m_frames[i].image);
    }
  }
  if (m_currentIndex >= 0 && m_currentIndex < m_frames.size()) {
    emit currentImageChanged(m_frames[m_currentIndex].image);
  }
}

void ImageSequence::applyAlphaCheckToCurrentFrame(
    const AlphaCheckParams &params) {
  if (m_currentIndex < 0 || m_currentIndex >= m_frames.size())
    return;

  if (processAlphaCheckOnImage(m_frames[m_currentIndex].image, params)) {
    emit imageModified(m_currentIndex, m_frames[m_currentIndex].image);
    emit currentImageChanged(m_frames[m_currentIndex].image);
  }
}
