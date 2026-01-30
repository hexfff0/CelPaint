#include "ColorReplaceDialog.h"
#include <QCheckBox>
#include <QColorDialog>
#include <QDebug>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QLabel>
#include <QPushButton>
#include <QSpinBox>
#include <QTableWidget>
#include <QVBoxLayout>

ColorReplaceDialog::ColorReplaceDialog(QWidget *parent) : QDialog(parent) {
  setWindowTitle(tr("Batch Palette (バッチパレット)"));
  setWindowFlags(windowFlags() & ~Qt::WindowContextHelpButtonHint);
  resize(400, 500);

  QVBoxLayout *mainLayout = new QVBoxLayout(this);

  // Toolbar
  QHBoxLayout *toolbarLayout = new QHBoxLayout();
  m_btnAdd = new QPushButton(tr("Add"), this);
  m_btnRemove = new QPushButton(tr("Remove"), this);
  m_btnClear = new QPushButton(tr("Clear"), this);

  connect(m_btnAdd, &QPushButton::clicked, this,
          &ColorReplaceDialog::onAddRowClicked);
  connect(m_btnRemove, &QPushButton::clicked, this,
          &ColorReplaceDialog::onRemoveRowClicked);
  connect(m_btnClear, &QPushButton::clicked, this,
          &ColorReplaceDialog::onClearAllClicked);

  toolbarLayout->addWidget(m_btnAdd);
  toolbarLayout->addWidget(m_btnRemove);
  toolbarLayout->addWidget(m_btnClear);
  toolbarLayout->addStretch();

  mainLayout->addLayout(toolbarLayout);

  // Table
  m_table = new QTableWidget(0, 5, this);
  QStringList headers;
  headers << tr("On") << tr("Source") << tr("->") << tr("Dest")
          << tr("Tolerance");
  m_table->setHorizontalHeaderLabels(headers);
  m_table->horizontalHeader()->setSectionResizeMode(0, QHeaderView::Fixed);
  m_table->horizontalHeader()->setSectionResizeMode(1, QHeaderView::Stretch);
  m_table->horizontalHeader()->setSectionResizeMode(
      2, QHeaderView::ResizeToContents);
  m_table->horizontalHeader()->setSectionResizeMode(3, QHeaderView::Stretch);
  m_table->horizontalHeader()->setSectionResizeMode(
      4, QHeaderView::ResizeToContents);
  m_table->setColumnWidth(0, 40);
  m_table->setSelectionBehavior(QAbstractItemView::SelectRows);
  m_table->setSelectionMode(QAbstractItemView::SingleSelection);

  // Connect click signals for color picking
  connect(m_table, &QTableWidget::cellDoubleClicked, this,
          &ColorReplaceDialog::onCellDoubleClicked);
  connect(m_table, &QTableWidget::cellClicked, this,
          &ColorReplaceDialog::onCellClicked);

  mainLayout->addWidget(m_table);

  // Footer actions
  QHBoxLayout *actionLayout = new QHBoxLayout();
  m_btnApplyCurrent = new QPushButton(tr("Apply (Current Frame)"), this);
  m_btnApplyAll = new QPushButton(tr("Apply All (Sequence)"), this);

  connect(m_btnApplyCurrent, &QPushButton::clicked, this,
          &ColorReplaceDialog::onApplyCurrentClicked);
  connect(m_btnApplyAll, &QPushButton::clicked, this,
          &ColorReplaceDialog::onApplyAllClicked);

  actionLayout->addWidget(m_btnApplyCurrent);
  actionLayout->addWidget(m_btnApplyAll);

  // Batch tolerance
  actionLayout->addStretch();
  QLabel *tolLabel = new QLabel(tr("Set All Tolerance:"), this);
  m_toleranceSpinner = new QSpinBox(this);
  m_toleranceSpinner->setRange(0, 255);
  m_toleranceSpinner->setValue(0);
  m_btnSetTolerance = new QPushButton(tr("Set"), this);
  connect(m_btnSetTolerance, &QPushButton::clicked, this,
          &ColorReplaceDialog::onSetAllToleranceClicked);

  actionLayout->addWidget(tolLabel);
  actionLayout->addWidget(m_toleranceSpinner);
  actionLayout->addWidget(m_btnSetTolerance);
  mainLayout->addLayout(actionLayout);

  // Add a default row
  addRow(Qt::white, Qt::white);
}

void ColorReplaceDialog::addRow(const QColor &src, const QColor &dest,
                                bool enabled, int tolerance) {
  int row = m_table->rowCount();
  m_table->insertRow(row);

  // Checkbox
  QTableWidgetItem *checkItem = new QTableWidgetItem();
  checkItem->setFlags(Qt::ItemIsUserCheckable | Qt::ItemIsEnabled |
                      Qt::ItemIsSelectable);
  checkItem->setCheckState(enabled ? Qt::Checked : Qt::Unchecked);
  // Store tolerance in data of this item for simplicity, or add another column
  // (keeping simpler for now)
  checkItem->setData(Qt::UserRole, tolerance);
  m_table->setItem(row, 0, checkItem);

  // Source Color
  QTableWidgetItem *srcItem = new QTableWidgetItem();
  srcItem->setFlags(Qt::ItemIsEnabled | Qt::ItemIsSelectable);
  srcItem->setBackground(src);
  // Store exact color
  srcItem->setData(Qt::UserRole, src);
  m_table->setItem(row, 1, srcItem);

  // Arrow
  QTableWidgetItem *arrowItem = new QTableWidgetItem("->");
  arrowItem->setTextAlignment(Qt::AlignCenter);
  arrowItem->setFlags(Qt::ItemIsEnabled | Qt::ItemIsSelectable);
  m_table->setItem(row, 2, arrowItem);

  // Dest Color
  QTableWidgetItem *destItem = new QTableWidgetItem();
  destItem->setFlags(Qt::ItemIsEnabled | Qt::ItemIsSelectable);
  destItem->setBackground(dest);
  destItem->setData(Qt::UserRole, dest);
  m_table->setItem(row, 3, destItem);

  // Tolerance
  QTableWidgetItem *tolItem = new QTableWidgetItem(QString::number(tolerance));
  tolItem->setTextAlignment(Qt::AlignCenter);
  tolItem->setFlags(Qt::ItemIsEnabled | Qt::ItemIsSelectable |
                    Qt::ItemIsEditable);
  m_table->setItem(row, 4, tolItem);
}

void ColorReplaceDialog::onAddRowClicked() {
  addRow(Qt::white, Qt::blue); // Default new row
}

void ColorReplaceDialog::onRemoveRowClicked() {
  int row = m_table->currentRow();
  if (row >= 0) {
    m_table->removeRow(row);
  }
}

void ColorReplaceDialog::onClearAllClicked() { m_table->setRowCount(0); }

void ColorReplaceDialog::onApplyCurrentClicked() { emit applyRequested(false); }

void ColorReplaceDialog::onApplyAllClicked() { emit applyRequested(true); }

void ColorReplaceDialog::onSetAllToleranceClicked() {
  int newTolerance = m_toleranceSpinner->value();
  // Apply to all checked (enabled) rows
  for (int i = 0; i < m_table->rowCount(); ++i) {
    QTableWidgetItem *checkItem = m_table->item(i, 0);
    if (checkItem && checkItem->checkState() == Qt::Checked) {
      QTableWidgetItem *tolItem = m_table->item(i, 4);
      if (tolItem) {
        tolItem->setText(QString::number(newTolerance));
      }
    }
  }
}

QList<ColorSwap> ColorReplaceDialog::getColorSwaps() const {
  QList<ColorSwap> swaps;
  for (int i = 0; i < m_table->rowCount(); ++i) {
    ColorSwap s;
    // Enabled?
    s.enabled = (m_table->item(i, 0)->checkState() == Qt::Checked);
    // Tolerance
    bool ok;
    int t = m_table->item(i, 4)->text().toInt(&ok);
    s.tolerance = ok ? t : 0;

    // Source
    s.source = m_table->item(i, 1)->data(Qt::UserRole).value<QColor>();
    // Dest
    s.dest = m_table->item(i, 3)->data(Qt::UserRole).value<QColor>();

    swaps.append(s);
  }
  return swaps;
}

void ColorReplaceDialog::addOrUpdateSourceColor(const QColor &src) {
  // Try to find if this source color already exists in the table
  for (int i = 0; i < m_table->rowCount(); ++i) {
    QColor existingSrc =
        m_table->item(i, 1)->data(Qt::UserRole).value<QColor>();
    if (existingSrc == src) {
      // Found it, select it
      m_table->selectRow(i);
      return;
    }
  }

  // Not found, add new row
  addRow(src, src); // Init desc as same as src (no change) by default
  m_table->scrollToBottom();
  m_table->selectRow(m_table->rowCount() - 1);
}

void ColorReplaceDialog::onCellClicked(int row, int column) {
  // Single click handler if needed, currently mainly using double click or
  // specific logic We could make single click open dialog too, but standard is
  // usually double click or button. However, for color swatches, single click
  // feels responsive.
  if (column == 1 || column == 3) {
    // Let's rely on double click for opening standard picker to avoid
    // accidental opens on selection
  }
}

void ColorReplaceDialog::onCellDoubleClicked(int row, int column) {
  if (column == 1) { // Source
    QColor current =
        m_table->item(row, column)->data(Qt::UserRole).value<QColor>();
    QColor newColor =
        QColorDialog::getColor(current, this, tr("Select Source Color"));
    if (newColor.isValid()) {
      m_table->item(row, column)->setBackground(newColor);
      m_table->item(row, column)->setData(Qt::UserRole, newColor);
    }
  } else if (column == 3) { // Dest
    QColor current =
        m_table->item(row, column)->data(Qt::UserRole).value<QColor>();
    QColor newColor =
        QColorDialog::getColor(current, this, tr("Select Destination Color"));
    if (newColor.isValid()) {
      m_table->item(row, column)->setBackground(newColor);
      m_table->item(row, column)->setData(Qt::UserRole, newColor);
    }
  }
}
