#ifndef UNDOCOMMANDS_H
#define UNDOCOMMANDS_H

#include "CelPaintTypes.h"
#include "ImageSequence.h"
#include <QUndoCommand>

class ColorSwapCommand : public QUndoCommand {
public:
  ColorSwapCommand(ImageSequence *sequence, const QList<ColorSwap> &swaps,
                   bool allFrames, QUndoCommand *parent = nullptr);

  void undo() override;
  void redo() override;

private:
  ImageSequence *m_sequence;
  QList<ColorSwap> m_swaps;
  bool m_allFrames;
  QMap<int, QImage> m_undoData;
};

class GuideCheckCommand : public QUndoCommand {
public:
  GuideCheckCommand(ImageSequence *sequence,
                    const QList<GuideColorParams> &params, bool allFrames,
                    QUndoCommand *parent = nullptr);

  void undo() override;
  void redo() override;

private:
  ImageSequence *m_sequence;
  QList<GuideColorParams> m_params;
  bool m_allFrames;
  QMap<int, QImage> m_undoData;
};

class AlphaCheckCommand : public QUndoCommand {
public:
  AlphaCheckCommand(ImageSequence *sequence, const AlphaCheckParams &params,
                    bool allFrames, QUndoCommand *parent = nullptr);

  void undo() override;
  void redo() override;

private:
  ImageSequence *m_sequence;
  AlphaCheckParams m_params;
  bool m_allFrames;
  QMap<int, QImage> m_undoData;
};

#endif // UNDOCOMMANDS_H
