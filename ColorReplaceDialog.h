#ifndef COLORREPLACEDIALOG_H
#define COLORREPLACEDIALOG_H

#include "ImageSequence.h" // For ColorSwap struct
#include <QColor>
#include <QDialog>
#include <QList>

class QTableWidget;
class QPushButton;
class QSpinBox;

class ColorReplaceDialog : public QDialog {
  Q_OBJECT

public:
  explicit ColorReplaceDialog(QWidget *parent = nullptr);

  QList<ColorSwap> getColorSwaps() const;

  // Adds a new row with the given source color.
  // If a row with this source already exists, update it or highlight it.
  void addOrUpdateSourceColor(const QColor &src);

signals:
  void applyRequested(bool allFrames);

private slots:
  void onAddRowClicked();
  void onRemoveRowClicked();
  void onClearAllClicked();
  void onApplyCurrentClicked();
  void onApplyAllClicked();

  void onCellDoubleClicked(int row, int column);
  void onCellClicked(int row, int column);
  void onSetAllToleranceClicked();

private:
  QTableWidget *m_table;
  QPushButton *m_btnAdd;
  QPushButton *m_btnRemove;
  QPushButton *m_btnClear;
  QPushButton *m_btnApplyCurrent;
  QPushButton *m_btnApplyAll;
  QSpinBox *m_toleranceSpinner;
  QPushButton *m_btnSetTolerance;

  void addRow(const QColor &src, const QColor &dest, bool enabled = true,
              int tolerance = 0);
  // Helpers to set background colors of cells
  void setCellColor(int row, int column, const QColor &c);
  QColor getCellColor(int row, int column) const;
};

#endif // COLORREPLACEDIALOG_H
