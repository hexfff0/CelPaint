#ifndef IMAGESEQUENCEPROVIDER_H
#define IMAGESEQUENCEPROVIDER_H

#include <QQuickImageProvider>

class ImageSequence;

class ImageSequenceProvider : public QQuickImageProvider {
public:
  explicit ImageSequenceProvider(ImageSequence *sequence);

  QImage requestImage(const QString &id, QSize *size,
                      const QSize &requestedSize) override;

private:
  ImageSequence *m_sequence;
};

#endif // IMAGESEQUENCEPROVIDER_H
