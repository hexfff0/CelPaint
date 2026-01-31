#include "GuideCheckModel.h"

GuideCheckModel::GuideCheckModel(QObject *parent) : QAbstractListModel(parent) {
  // Default: Red, Blue, Green
  addCheck(Qt::red, QColor("yellow"), 0);
  addCheck(Qt::blue, QColor("yellow"), 0);
  addCheck(Qt::green, QColor("yellow"), 0);
}

int GuideCheckModel::rowCount(const QModelIndex &parent) const {
  if (parent.isValid())
    return 0;
  return m_checks.size();
}

QVariant GuideCheckModel::data(const QModelIndex &index, int role) const {
  if (!index.isValid() || index.row() >= m_checks.size())
    return QVariant();

  const auto &check = m_checks.at(index.row());

  switch (role) {
  case SourceColorRole:
    return check.sourceColor;
  case SelectionColorRole:
    return check.selectionColor;
  case ToleranceRole:
    return check.tolerance;
  case EnabledRole:
    return check.enabled;
  default:
    return QVariant();
  }
}

QHash<int, QByteArray> GuideCheckModel::roleNames() const {
  QHash<int, QByteArray> roles;
  roles[SourceColorRole] = "sourceColor";
  roles[SelectionColorRole] = "selectionColor";
  roles[ToleranceRole] = "tolerance";
  roles[EnabledRole] = "enabled";
  return roles;
}

void GuideCheckModel::addCheck(const QColor &source, const QColor &selection,
                               int tolerance) {
  beginInsertRows(QModelIndex(), m_checks.size(), m_checks.size());
  GuideColorParams p;
  p.sourceColor = source;
  p.selectionColor = selection;
  p.tolerance = tolerance;
  p.enabled = true;
  // Radius/Thickness are set globally later, but initialize defaults
  p.radius = 10;
  p.thickness = 2;
  m_checks.append(p);
  endInsertRows();
}

void GuideCheckModel::removeCheck(int index) {
  if (index < 0 || index >= m_checks.size())
    return;

  beginRemoveRows(QModelIndex(), index, index);
  m_checks.removeAt(index);
  endRemoveRows();
}

void GuideCheckModel::setSourceColor(int index, const QColor &color) {
  if (index < 0 || index >= m_checks.size())
    return;
  m_checks[index].sourceColor = color;
  emit dataChanged(this->index(index), this->index(index), {SourceColorRole});
}

void GuideCheckModel::setSelectionColor(int index, const QColor &color) {
  if (index < 0 || index >= m_checks.size())
    return;
  m_checks[index].selectionColor = color;
  emit dataChanged(this->index(index), this->index(index),
                   {SelectionColorRole});
}

void GuideCheckModel::setTolerance(int index, int tolerance) {
  if (index < 0 || index >= m_checks.size())
    return;
  m_checks[index].tolerance = tolerance;
  emit dataChanged(this->index(index), this->index(index), {ToleranceRole});
}

void GuideCheckModel::setEnabled(int index, bool enabled) {
  if (index < 0 || index >= m_checks.size())
    return;
  m_checks[index].enabled = enabled;
  emit dataChanged(this->index(index), this->index(index), {EnabledRole});
}

void GuideCheckModel::setAllTolerances(int tolerance) {
  if (m_checks.isEmpty())
    return;
  for (auto &check : m_checks) {
    check.tolerance = tolerance;
  }
  emit dataChanged(this->index(0), this->index(m_checks.size() - 1),
                   {ToleranceRole});
}

QList<GuideColorParams> GuideCheckModel::getChecks(int radius,
                                                   int thickness) const {
  QList<GuideColorParams> result;
  for (auto p : m_checks) {
    if (p.enabled) {
      p.radius = radius;
      p.thickness = thickness;
      result.append(p);
    }
  }
  return result;
}
