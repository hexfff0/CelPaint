#ifndef COLORSWAPMODEL_H
#define COLORSWAPMODEL_H

#include "CelPaintTypes.h"
#include <QAbstractListModel>
#include <QList>
#include <QtGui/QColor>


class ColorSwapModel : public QAbstractListModel {
  Q_OBJECT
  Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
  enum Roles {
    SourceColorRole = Qt::UserRole + 1,
    DestColorRole,
    EnabledRole,
    ToleranceRole
  };

  explicit ColorSwapModel(QObject *parent = nullptr);

  // QAbstractListModel interface
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;
  QVariant data(const QModelIndex &index,
                int role = Qt::DisplayRole) const override;
  bool setData(const QModelIndex &index, const QVariant &value,
               int role) override;
  Qt::ItemFlags flags(const QModelIndex &index) const override;
  QHash<int, QByteArray> roleNames() const override;

  // QML invokable methods
  Q_INVOKABLE void addSwap(const QColor &src, const QColor &dest,
                           int tolerance = 0);
  Q_INVOKABLE void addSourceColor(const QColor &src);
  Q_INVOKABLE void removeSwap(int index);
  Q_INVOKABLE void clear();
  Q_INVOKABLE void setDestColor(int index, const QColor &color);
  Q_INVOKABLE void setSourceColor(int index, const QColor &color);
  Q_INVOKABLE void setAllTolerance(int tolerance);

  // Accessors
  int count() const;
  QList<ColorSwap> getSwaps() const;

signals:
  void countChanged();

private:
  QList<ColorSwap> m_swaps;
};

#endif // COLORSWAPMODEL_H
