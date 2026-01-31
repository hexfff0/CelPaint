#include "ColorSwapModel.h"

ColorSwapModel::ColorSwapModel(QObject *parent) : QAbstractListModel(parent) {}

int ColorSwapModel::rowCount(const QModelIndex &parent) const {
  if (parent.isValid())
    return 0;
  return m_swaps.size();
}

QVariant ColorSwapModel::data(const QModelIndex &index, int role) const {
  if (!index.isValid() || index.row() < 0 || index.row() >= m_swaps.size())
    return QVariant();

  const ColorSwap &swap = m_swaps[index.row()];

  switch (role) {
  case SourceColorRole:
    return swap.source;
  case DestColorRole:
    return swap.dest;
  case EnabledRole:
    return swap.enabled;
  case ToleranceRole:
    return swap.tolerance;
  default:
    return QVariant();
  }
}

bool ColorSwapModel::setData(const QModelIndex &index, const QVariant &value,
                             int role) {
  if (!index.isValid() || index.row() < 0 || index.row() >= m_swaps.size())
    return false;

  ColorSwap &swap = m_swaps[index.row()];
  bool changed = false;

  switch (role) {
  case DestColorRole:
    if (swap.dest != value.value<QColor>()) {
      swap.dest = value.value<QColor>();
      changed = true;
    }
    break;
  case EnabledRole:
    if (swap.enabled != value.toBool()) {
      swap.enabled = value.toBool();
      changed = true;
    }
    break;
  case ToleranceRole:
    if (swap.tolerance != value.toInt()) {
      swap.tolerance = value.toInt();
      changed = true;
    }
    break;
  default:
    return false;
  }

  if (changed) {
    emit dataChanged(index, index, {role});
  }
  return changed;
}

Qt::ItemFlags ColorSwapModel::flags(const QModelIndex &index) const {
  if (!index.isValid())
    return Qt::NoItemFlags;
  return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

QHash<int, QByteArray> ColorSwapModel::roleNames() const {
  return {{SourceColorRole, "sourceColor"},
          {DestColorRole, "destColor"},
          {EnabledRole, "enabled"},
          {ToleranceRole, "tolerance"}};
}

void ColorSwapModel::addSwap(const QColor &src, const QColor &dest,
                             int tolerance) {
  beginInsertRows(QModelIndex(), m_swaps.size(), m_swaps.size());
  m_swaps.append({src, dest, true, tolerance});
  endInsertRows();
  emit countChanged();
}

void ColorSwapModel::addSourceColor(const QColor &src) {
  // Check if this source color already exists
  for (int i = 0; i < m_swaps.size(); ++i) {
    if (m_swaps[i].source == src) {
      // Already exists, just return (could emit signal to highlight)
      return;
    }
  }
  // Add new with dest same as source (no change by default)
  addSwap(src, src, 0);
}

void ColorSwapModel::removeSwap(int index) {
  if (index < 0 || index >= m_swaps.size())
    return;

  beginRemoveRows(QModelIndex(), index, index);
  m_swaps.removeAt(index);
  endRemoveRows();
  emit countChanged();
}

void ColorSwapModel::clear() {
  if (m_swaps.isEmpty())
    return;

  beginResetModel();
  m_swaps.clear();
  endResetModel();
  emit countChanged();
}

void ColorSwapModel::setDestColor(int index, const QColor &color) {
  if (index < 0 || index >= m_swaps.size())
    return;

  m_swaps[index].dest = color;
  QModelIndex modelIndex = createIndex(index, 0);
  emit dataChanged(modelIndex, modelIndex, {DestColorRole});
}

void ColorSwapModel::setSourceColor(int index, const QColor &color) {
  if (index < 0 || index >= m_swaps.size())
    return;

  m_swaps[index].source = color;
  QModelIndex modelIndex = createIndex(index, 0);
  emit dataChanged(modelIndex, modelIndex, {SourceColorRole});
}

void ColorSwapModel::setAllTolerance(int tolerance) {
  for (int i = 0; i < m_swaps.size(); ++i) {
    if (m_swaps[i].enabled) {
      m_swaps[i].tolerance = tolerance;
    }
  }
  if (!m_swaps.isEmpty()) {
    emit dataChanged(createIndex(0, 0), createIndex(m_swaps.size() - 1, 0),
                     {ToleranceRole});
  }
}

int ColorSwapModel::count() const { return m_swaps.size(); }

QList<ColorSwap> ColorSwapModel::getSwaps() const { return m_swaps; }
