#ifndef TIMELINEMODEL_H
#define TIMELINEMODEL_H

#include "ImageSequence.h"
#include <QAbstractListModel>


class TimelineModel : public QAbstractListModel {
  Q_OBJECT

public:
  enum Roles { ImageIdRole = Qt::UserRole + 1, LabelRole, IsSelectedRole };

  explicit TimelineModel(ImageSequence *sequence, QObject *parent = nullptr);

  // QAbstractListModel interface
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;
  QVariant data(const QModelIndex &index,
                int role = Qt::DisplayRole) const override;
  QHash<int, QByteArray> roleNames() const override;

public slots:
  void onSequenceLoaded();
  void onCurrentIndexChanged(int index);
  void onImageModified(int index);

private:
  ImageSequence *m_sequence;
  int m_selectedIndex = -1;
};

#endif // TIMELINEMODEL_H
