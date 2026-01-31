#include "TimelineModel.h"
#include "ImageSequence.h"

TimelineModel::TimelineModel(ImageSequence *sequence, QObject *parent)
    : QAbstractListModel(parent), m_sequence(sequence), m_selectedIndex(-1) {

  connect(m_sequence, &ImageSequence::sequenceLoaded, this,
          &TimelineModel::onSequenceLoaded);
  connect(m_sequence, &ImageSequence::currentIndexChanged, this,
          &TimelineModel::onCurrentIndexChanged);
  connect(m_sequence, &ImageSequence::imageModified, this,
          &TimelineModel::onImageModified);
}

int TimelineModel::rowCount(const QModelIndex &parent) const {
  if (parent.isValid())
    return 0;
  return m_sequence->count();
}

QVariant TimelineModel::data(const QModelIndex &index, int role) const {
  if (!index.isValid() || index.row() < 0 || index.row() >= m_sequence->count())
    return QVariant();

  switch (role) {
  case ImageIdRole:
    return index.row();
  case LabelRole:
    return QString::number(index.row() + 1);
  case IsSelectedRole:
    return index.row() == m_selectedIndex;
  default:
    return QVariant();
  }
}

QHash<int, QByteArray> TimelineModel::roleNames() const {
  return {{ImageIdRole, "imageId"},
          {LabelRole, "label"},
          {IsSelectedRole, "isSelected"}};
}

void TimelineModel::onSequenceLoaded() {
  beginResetModel();
  m_selectedIndex = m_sequence->count() > 0 ? 0 : -1;
  endResetModel();
}

void TimelineModel::onCurrentIndexChanged(int index) {
  int oldIndex = m_selectedIndex;
  m_selectedIndex = index;

  if (oldIndex >= 0 && oldIndex < m_sequence->count()) {
    QModelIndex modelIndex = createIndex(oldIndex, 0);
    emit dataChanged(modelIndex, modelIndex, {IsSelectedRole});
  }
  if (index >= 0 && index < m_sequence->count()) {
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {IsSelectedRole});
  }
}

void TimelineModel::onImageModified(int index) {
  if (index >= 0 && index < m_sequence->count()) {
    QModelIndex modelIndex = createIndex(index, 0);
    // Signal that image changed so QML can refresh thumbnail
    emit dataChanged(modelIndex, modelIndex, {ImageIdRole});
  }
}
