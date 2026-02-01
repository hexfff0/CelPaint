#include "UndoCommands.h"

// --- ColorSwapCommand ---
ColorSwapCommand::ColorSwapCommand(ImageSequence *sequence,
                                   const QList<ColorSwap> &swaps,
                                   bool allFrames, QUndoCommand *parent)
    : QUndoCommand(parent), m_sequence(sequence), m_swaps(swaps),
      m_allFrames(allFrames) {
  setText(allFrames ? "Batch Color Swap" : "Color Swap");
}

void ColorSwapCommand::undo() {
  QMapIterator<int, QImage> i(m_undoData);
  while (i.hasNext()) {
    i.next();
    m_sequence->setImage(i.key(), i.value());
  }
}

void ColorSwapCommand::redo() {
  QMap<int, QImage> result;
  if (m_allFrames) {
    result = m_sequence->replaceColorsInAllFrames(m_swaps);
  } else {
    result = m_sequence->replaceColorsInCurrentFrame(m_swaps);
  }

  // Capture undo data only on the first run (when it's empty)
  // Logic: First run (pushed to stack) -> returns original images.
  // Subsequent redo (after undo) -> returns restored images (which are same as original).
  // So we can just set it if empty.
  if (m_undoData.isEmpty()) {
    m_undoData = result;
  }
}

// --- GuideCheckCommand ---
GuideCheckCommand::GuideCheckCommand(ImageSequence *sequence,
                                     const QList<GuideColorParams> &params,
                                     bool allFrames, QUndoCommand *parent)
    : QUndoCommand(parent), m_sequence(sequence), m_params(params),
      m_allFrames(allFrames) {
  setText(allFrames ? "Batch Guide Check" : "Guide Check");
}

void GuideCheckCommand::undo() {
  QMapIterator<int, QImage> i(m_undoData);
  while (i.hasNext()) {
    i.next();
    m_sequence->setImage(i.key(), i.value());
  }
}

void GuideCheckCommand::redo() {
  QMap<int, QImage> result;
  if (m_allFrames) {
    result = m_sequence->applyGuideCheckToAllFrames(m_params);
  } else {
    result = m_sequence->applyGuideCheckToCurrentFrame(m_params);
  }

  if (m_undoData.isEmpty()) {
    m_undoData = result;
  }
}

// --- AlphaCheckCommand ---
AlphaCheckCommand::AlphaCheckCommand(ImageSequence *sequence,
                                     const AlphaCheckParams &params,
                                     bool allFrames, QUndoCommand *parent)
    : QUndoCommand(parent), m_sequence(sequence), m_params(params),
      m_allFrames(allFrames) {
  setText(allFrames ? "Batch Alpha Check" : "Alpha Check");
}

void AlphaCheckCommand::undo() {
  QMapIterator<int, QImage> i(m_undoData);
  while (i.hasNext()) {
    i.next();
    m_sequence->setImage(i.key(), i.value());
  }
}

void AlphaCheckCommand::redo() {
  QMap<int, QImage> result;
  if (m_allFrames) {
    result = m_sequence->applyAlphaCheckToAllFrames(m_params);
  } else {
    result = m_sequence->applyAlphaCheckToCurrentFrame(m_params);
  }

  if (m_undoData.isEmpty()) {
    m_undoData = result;
  }
}
