#ifndef IMAGESEQUENCE_H
#define IMAGESEQUENCE_H

#include <QColor>
#include <QDir>
#include <QImage>
#include <QList>
#include <QObject>
#include <QString>

struct ColorSwap {
  QColor source;
  QColor dest;
  bool enabled = true;
  int tolerance = 0;
};

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

  // Core Logic: Color Replacement
  void replaceColorsInCurrentFrame(const QList<ColorSwap> &swaps);
  void replaceColorsInAllFrames(const QList<ColorSwap> &swaps);

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

  void replaceColorsInImage(QImage &img, const QList<ColorSwap> &swaps);
};

#endif // IMAGESEQUENCE_H
