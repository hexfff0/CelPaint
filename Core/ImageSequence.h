#ifndef IMAGESEQUENCE_H
#define IMAGESEQUENCE_H

#include "CelPaintTypes.h"
#include <QDir>
#include <QImage>
#include <QList>
#include <QMap>
#include <QObject>
#include <QString>
#include <QtGui/QColor>

class ImageSequence : public QObject {
  Q_OBJECT
  Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY
                 currentIndexChanged)
  Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
  explicit ImageSequence(QObject *parent = nullptr);

  // File Operations
  void loadSequence(const QStringList &filePaths);
  void saveSequence(const QString &outputDir, const QString &format = "PNG");

  // Image Access
  QImage currentImage() const;
  int currentIndex() const;
  int count() const;
  QString currentFilePath() const;
  QImage imageAt(int index) const;

  // Manipulation
  void setCurrentIndex(int index);
  void setImage(int index, const QImage &image);

  // Core Logic: Color Replacement
  QMap<int, QImage> replaceColorsInCurrentFrame(const QList<ColorSwap> &swaps);
  QMap<int, QImage> replaceColorsInAllFrames(const QList<ColorSwap> &swaps);

  // New Feature: Check Guide Color
  QMap<int, QImage> applyGuideCheckToAllFrames(const QList<GuideColorParams> &params);
  QMap<int, QImage> applyGuideCheckToCurrentFrame(const QList<GuideColorParams> &params);

  // New Feature: Alpha Check
  QMap<int, QImage> applyAlphaCheckToAllFrames(const AlphaCheckParams &params);
  QMap<int, QImage> applyAlphaCheckToCurrentFrame(const AlphaCheckParams &params);

signals:
  void sequenceLoaded();
  void currentIndexChanged(int index);
  void countChanged();
  void currentImageChanged(const QImage &image);
  void imageModified(int index, const QImage &image);

private:
  struct Frame {
    QString originalPath;
    QImage image;
  };

  QList<Frame> m_frames;
  int m_currentIndex = -1;

  bool replaceColorsInImage(QImage &img, const QList<ColorSwap> &swaps);
};

#endif // IMAGESEQUENCE_H
