#ifndef GUIDECHECKMODEL_H
#define GUIDECHECKMODEL_H

#include "CelPaintTypes.h"
#include <QAbstractListModel>
#include <QColor>
#include <QList>
#include <QObject>

class GuideCheckModel : public QAbstractListModel {
  Q_OBJECT
public:
  enum GuideCheckRoles {
    SourceColorRole = Qt::UserRole + 1,
    SelectionColorRole,
    ToleranceRole,
    EnabledRole
  };

  explicit GuideCheckModel(QObject *parent = nullptr);

  int rowCount(const QModelIndex &parent = QModelIndex()) const override;
  QVariant data(const QModelIndex &index,
                int role = Qt::DisplayRole) const override;
  QHash<int, QByteArray> roleNames() const override;

  Q_INVOKABLE void addCheck(const QColor &source, const QColor &selection,
                            int tolerance = 0);
  Q_INVOKABLE void removeCheck(int index);
  Q_INVOKABLE void setSourceColor(int index, const QColor &color);
  Q_INVOKABLE void setSelectionColor(int index, const QColor &color);
  Q_INVOKABLE void setTolerance(int index, int tolerance);
  Q_INVOKABLE void setEnabled(int index, bool enabled);
  Q_INVOKABLE void setAllTolerances(int tolerance);

  // Helper to get all checks for processing, adding the global radius/thickness
  // settings
  QList<GuideColorParams> getChecks(int radius, int thickness) const;

private:
  QList<GuideColorParams> m_checks;
};

#endif // GUIDECHECKMODEL_H
