#include "./ui_main.h"
#include "ColorReplaceDialog.h"
#include "ImageSequence.h"
#include "main.h"


#include <QApplication>
#include <QDockWidget>
#include <QFileDialog>
#include <QMenuBar>
#include <QMessageBox>
#include <QMouseEvent>
#include <QStatusBar>
#include <QWheelEvent>

Main::Main(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::Main),
      m_sequence(new ImageSequence(this)), m_colorReplaceDlg(nullptr),
      m_scaleFactor(1.0) {
  ui->setupUi(this);
  setupUiProgrammatically();

  // Connect Sequence Signals
  connect(m_sequence, &ImageSequence::sequenceLoaded, this,
          &Main::onSequenceLoaded);
  connect(m_sequence, &ImageSequence::currentImageChanged, this,
          &Main::onCurrentImageChanged);

  // Connect Timeline
  connect(m_timelineList, &QListWidget::itemClicked, this,
          &Main::onTimelineItemClicked);
}

Main::~Main() { delete ui; }

void Main::setupUiProgrammatically() {
  // 1. Central Widget (Image Preview)
  m_scrollArea = new QScrollArea(this);
  m_scrollArea->setBackgroundRole(QPalette::Dark);
  m_scrollArea->setAlignment(Qt::AlignCenter);

  m_imageLabel = new QLabel(this);
  m_imageLabel->setSizePolicy(QSizePolicy::Ignored, QSizePolicy::Ignored);
  m_imageLabel->setScaledContents(false);
  // Install event filter for color picking
  m_imageLabel->installEventFilter(this);

  m_scrollArea->setWidget(m_imageLabel);
  setCentralWidget(m_scrollArea);

  // 2. Dock Widget (Timeline)
  QDockWidget *dock = new QDockWidget(tr("Timeline"), this);
  dock->setAllowedAreas(Qt::BottomDockWidgetArea | Qt::TopDockWidgetArea);
  m_timelineList = new QListWidget(dock);
  m_timelineList->setViewMode(QListView::IconMode);
  m_timelineList->setIconSize(QSize(100, 100));
  m_timelineList->setResizeMode(QListWidget::Adjust);
  m_timelineList->setFixedHeight(150);

  dock->setWidget(m_timelineList);
  addDockWidget(Qt::BottomDockWidgetArea, dock);

  // 3. Menus
  QMenu *fileMenu = menuBar()->addMenu(tr("&File"));
  QAction *actOpen = fileMenu->addAction(tr("&Open Sequence..."), this,
                                         &Main::onActionOpenTriggered);
  actOpen->setShortcut(QKeySequence::Open);

  QAction *actExport = fileMenu->addAction(tr("&Export..."), this,
                                           &Main::onActionExportTriggered);

  QMenu *toolMenu = menuBar()->addMenu(tr("&Tools"));
  QAction *actColorReplace = toolMenu->addAction(
      tr("Batch Palette (色置換)"), this, &Main::onActionColorReplaceTriggered);

  statusBar()->showMessage(tr("Ready"));
}

void Main::onActionOpenTriggered() {
  QStringList files = QFileDialog::getOpenFileNames(
      this, tr("Open Image Sequence"), QString(),
      tr("Images (*.png *.bmp *.jpg *.jpeg *.tif *.tiff);;All Files (*)"));

  if (!files.isEmpty()) {
    // Sort files to ensure sequence order
    files.sort();
    m_sequence->loadSequence(files);
  }
}

void Main::onActionExportTriggered() {
  if (m_sequence->count() == 0)
    return;

  QString dir =
      QFileDialog::getExistingDirectory(this, tr("Select Export Directory"));
  if (!dir.isEmpty()) {
    m_sequence->saveSequence(dir);
    QMessageBox::information(this, tr("Success"),
                             tr("Sequence exported successfully."));
  }
}

void Main::onActionColorReplaceTriggered() {
  if (!m_colorReplaceDlg) {
    m_colorReplaceDlg = new ColorReplaceDialog(this);
    connect(m_colorReplaceDlg, &ColorReplaceDialog::applyRequested, this,
            &Main::applyColorReplacement);
  }
  m_colorReplaceDlg->show();
  m_colorReplaceDlg->raise();
  m_colorReplaceDlg->activateWindow();
}

void Main::onSequenceLoaded() {
  updateTimeline();
  statusBar()->showMessage(tr("Loaded %1 frames").arg(m_sequence->count()));
  m_scaleFactor = 1.0;
  updateImageDisplay();
}

void Main::onCurrentImageChanged(const QImage &image) {
  Q_UNUSED(image);
  updateImageDisplay();

  // Sync selection in timeline if not already
  int index = m_sequence->currentIndex();
  if (index >= 0 && index < m_timelineList->count()) {
    QListWidgetItem *item = m_timelineList->item(index);
    if (!item->isSelected()) {
      m_timelineList->blockSignals(true);
      item->setSelected(true);
      m_timelineList->scrollToItem(item);
      m_timelineList->blockSignals(false);
    }
  }
}

void Main::updateImageDisplay() {
  QImage img = m_sequence->currentImage();
  if (img.isNull())
    return;

  // Apply scaling
  QPixmap pix = QPixmap::fromImage(img);
  if (m_scaleFactor != 1.0) {
    QSize newSize = pix.size() * m_scaleFactor;
    pix = pix.scaled(newSize, Qt::KeepAspectRatio, Qt::FastTransformation);
  }

  m_imageLabel->setPixmap(pix);
  m_imageLabel->resize(pix.size());

  statusBar()->showMessage(tr("Zoom: %1%").arg(int(m_scaleFactor * 100)));
}

void Main::onTimelineItemClicked(QListWidgetItem *item) {
  int index = m_timelineList->row(item);
  m_sequence->setCurrentIndex(index);
}

void Main::updateTimeline() {
  m_timelineList->clear();
  for (int i = 0; i < m_sequence->count(); ++i) {
    QImage img = m_sequence->imageAt(i);
    // Create thumbnail
    QIcon icon(QPixmap::fromImage(img).scaled(100, 100, Qt::KeepAspectRatio,
                                              Qt::SmoothTransformation));
    QString label = QString::number(i + 1);

    QListWidgetItem *item = new QListWidgetItem(icon, label);
    m_timelineList->addItem(item);
  }

  if (m_sequence->count() > 0) {
    m_timelineList->item(0)->setSelected(true);
  }
}

void Main::applyColorReplacement(bool allFrames) {
  if (!m_colorReplaceDlg)
    return;

  QList<ColorSwap> swaps = m_colorReplaceDlg->getColorSwaps();

  if (allFrames) {
    m_sequence->replaceColorsInAllFrames(swaps);
    // We need to refresh the timeline icons as the images changed
    updateTimeline();
    statusBar()->showMessage(tr("Replaced colors in all frames."));
  } else {
    m_sequence->replaceColorsInCurrentFrame(swaps);
    // Update specific timeline item
    int idx = m_sequence->currentIndex();
    if (idx >= 0) {
      QImage img = m_sequence->currentImage();
      QIcon icon(QPixmap::fromImage(img).scaled(100, 100, Qt::KeepAspectRatio,
                                                Qt::SmoothTransformation));
      m_timelineList->item(idx)->setIcon(icon);
    }
    statusBar()->showMessage(tr("Replaced colors in current frame."));
  }
}

bool Main::eventFilter(QObject *watched, QEvent *event) {
  if (watched == m_imageLabel && event->type() == QEvent::MouseButtonPress) {
    QMouseEvent *me = static_cast<QMouseEvent *>(event);
    if (me->button() == Qt::LeftButton && m_colorReplaceDlg &&
        m_colorReplaceDlg->isVisible()) {

      QPixmap pix = m_imageLabel->pixmap(Qt::ReturnByValue); // Qt 6
      if (!pix.isNull()) {
        QImage img = pix.toImage();

        int x = me->pos().x();
        int y = me->pos().y();

        // This coordinates are on the SCALED image since m_imageLabel size
        // matches pixmap size
        if (x >= 0 && x < img.width() && y >= 0 && y < img.height()) {
          QColor c = img.pixelColor(x, y);
          // Add or Select in Dialog
          m_colorReplaceDlg->addOrUpdateSourceColor(c);
          return true; // consumed
        }
      }
    }
  }
  return QMainWindow::eventFilter(watched, event);
}

void Main::wheelEvent(QWheelEvent *event) {
  if (event->modifiers() & Qt::ControlModifier) {
    const int delta = event->angleDelta().y();
    if (delta > 0)
      zoomIn();
    else
      zoomOut();

    event->accept();
  } else {
    QMainWindow::wheelEvent(event);
  }
}

void Main::zoomIn() {
  m_scaleFactor *= 1.25;
  updateImageDisplay();
}

void Main::zoomOut() {
  m_scaleFactor *= 0.8;
  updateImageDisplay();
}
