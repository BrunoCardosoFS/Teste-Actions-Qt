#ifndef PLAYLISTDELEGATE_H
#define PLAYLISTDELEGATE_H

#pragma once

#include <QStyledItemDelegate>
#include <QPainter>

class PlaylistDelegate : public QStyledItemDelegate{

public:
    PlaylistDelegate(QObject *parent = nullptr);
    ~PlaylistDelegate();

    QSize sizeHint(const QStyleOptionViewItem &option,
                   const QModelIndex &index) const override;
    void paint(QPainter *p, const QStyleOptionViewItem &option,
               const QModelIndex &index) const override;

signals:
};

#endif // PLAYLISTDELEGATE_H
