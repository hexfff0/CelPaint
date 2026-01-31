#include "ImageSequenceProvider.h"
#include "ImageSequence.h"
#include <QUrlQuery>

ImageSequenceProvider::ImageSequenceProvider(ImageSequence *sequence)
    : QQuickImageProvider(QQuickImageProvider::Image), m_sequence(sequence) {}

QImage ImageSequenceProvider::requestImage(const QString &id, QSize *size,
                                           const QSize &requestedSize) {
  QImage img;

  // Parse id - format: "current" or index number, with optional query params
  // Examples: "current?r=1", "0?thumbnail=true&r=2"
  QString cleanId = id;
  bool isThumbnail = false;

  int queryPos = id.indexOf('?');
  if (queryPos >= 0) {
    QString queryString = id.mid(queryPos + 1);
    cleanId = id.left(queryPos);

    QUrlQuery query(queryString);
    isThumbnail = query.queryItemValue("thumbnail") == "true";
  }

  if (cleanId == "current") {
    img = m_sequence->currentImage();
  } else {
    bool ok;
    int index = cleanId.toInt(&ok);
    if (ok) {
      img = m_sequence->imageAt(index);
    }
  }

  if (img.isNull()) {
    // Return a placeholder or empty image
    img = QImage(1, 1, QImage::Format_ARGB32);
    img.fill(Qt::transparent);
  }

  if (size) {
    *size = img.size();
  }

  // Handle thumbnail request
  if (isThumbnail && requestedSize.isValid()) {
    return img.scaled(requestedSize, Qt::KeepAspectRatio,
                      Qt::SmoothTransformation);
  }

  // Handle requested size scaling
  if (requestedSize.isValid() && requestedSize.width() > 0 &&
      requestedSize.height() > 0) {
    return img.scaled(requestedSize, Qt::KeepAspectRatio,
                      Qt::SmoothTransformation);
  }

  return img;
}
