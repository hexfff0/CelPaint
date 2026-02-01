#ifndef CELPAINTTYPES_H
#define CELPAINTTYPES_H

#include <QtGui/QColor>

struct ColorSwap {
  QColor source;
  QColor dest;
  bool enabled = true;
  int tolerance = 0;
};

struct GuideColorParams {
  QColor sourceColor;
  QColor selectionColor;
  int radius = 10;
  int thickness = 2;
  int tolerance = 0;
  bool enabled = true;
};

struct AlphaCheckParams {
  QColor crossColor = Qt::red;
  int crossSize = 10;
  int thickness = 2;
  bool applyToAll = false;
};

#endif // CORE_TYPES_H
