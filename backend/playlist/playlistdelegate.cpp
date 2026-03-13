#include "playlistdelegate.h"

#include "../models.h"

#include <QDebug>
#include <QTime>
#include <QPainterPath>

PlaylistDelegate::PlaylistDelegate(QObject *parent):QStyledItemDelegate{parent}{}

PlaylistDelegate::~PlaylistDelegate(){}

QSize PlaylistDelegate::sizeHint(const QStyleOptionViewItem& option, const QModelIndex& index) const{
    int type = index.data(PlaylistItemRoles::TypeRole).toInt();
    int blockType = index.data(PlaylistItemRoles::BlockTypeRole).toInt();

    switch (type) {
    case (int)ItemType::BlockMarker:
        return QSize(0, 50);
        break;

    case (int)ItemType::StartMarker:
        if(blockType == (int)BlockType::Commercial) return QSize(0, 30);
        if(blockType == (int)BlockType::Music) return QSize(0, 12);
        break;

    case (int)ItemType::EndMarker:
        if(blockType == (int)BlockType::Commercial) return QSize(0, 30);
        if(blockType == (int)BlockType::Music) return QSize(0, 15);
        break;

    default:
        return QSize(0, 45);
        break;
    }

    return QSize(0, 45);
}

void PlaylistDelegate::paint(QPainter* p, const QStyleOptionViewItem& option, const QModelIndex& index) const{
    p->save();
    p->setCompositionMode(QPainter::CompositionMode_Source);

    QRect r = option.rect;

    int x = r.x() + 5;
    int y = r.y();
    int width = r.width() - 10;
    int height = r.height();

    r.setX(x);
    r.setWidth(width);

    QFont f = p->font();
    f.setBold(true);
    p->setFont(f);
    p->setPen(Qt::white);

    int blockType = index.data(PlaylistItemRoles::BlockTypeRole).toInt();

    switch (index.data(PlaylistItemRoles::TypeRole).toInt()) {
    case (int)ItemType::BlockMarker:
        r.setY(r.y() + 5);
        r.setHeight(r.height() - 2);

        p->setClipPath(roundedRect(r, 7, 7, 0, 0));

        p->fillRect(r, QColor(0XFF1F232C));

        f.setPointSize(13);
        p->setFont(f);
        p->drawText(r.adjusted(10,0,0,0), Qt::AlignVCenter, index.data(PlaylistItemRoles::TitleRole).toString());
        p->restore();
        return;
        break;

    case (int)ItemType::StartMarker:
        if (blockType == (int)BlockType::Commercial){
            p->fillRect(r, QColor(0XFF1F232C));
            p->drawText(r.adjusted(10,0,0,0), Qt::AlignVCenter, "↱ Bloco comercial");
            p->restore();
            return;
        }

        if (blockType == (int)BlockType::Music){
            r.setY(r.y() + 2);

            p->fillRect(r, QColor(0XFF1F232C));
            p->restore();
            return;
        }

    case (int)ItemType::EndMarker:
        if (blockType == (int)BlockType::Commercial){
            p->fillRect(r, QColor(0XFF1F232C));

            p->setPen(Qt::white);
            p->drawText(r.adjusted(10,0,0,0), Qt::AlignVCenter, "↳ Bloco comercial");
            p->restore();
            return;
        }

        if (blockType == (int)BlockType::Music){
            r.setHeight(r.height() - 5);
            p->setClipPath(roundedRect(r, 0,0,7,7));
            p->fillRect(r, QColor(0XFF1F232C));
            p->restore();
            return;
        }

    default:
        break;
    }

    p->setPen(Qt::NoPen);
    p->fillRect(r, QColor(0XFF1F232C));

    x = x+10;
    width = width-20;
    r.setX(x);
    r.setWidth(width);

    const QString title = index.data(PlaylistItemRoles::TitleRole).toString();
    const int position = index.data(PlaylistItemRoles::PositionRole).toInt();
    const int duration = index.data(PlaylistItemRoles::DurationRole).toInt();
    const float progress = (float)position/duration;

    p->setClipPath(roundedRect(r, 7, 7, 7, 7));


    QColor bg1 = QColor(0xFF418DB4);
    QColor bg2 = QColor(0xFF0066A5);

    switch(index.data(PlaylistItemRoles::TypeRole).toInt()){
    case ((int)ItemType::Commercial):
        bg1 = QColor(0xFF68B127);
        bg2 = QColor(0xFF3C8808);
        break;
    case ((int)ItemType::Jingle):
        bg1 = QColor(0xFFFE9818);
        bg2 = QColor(0xFFE66800);
        break;
    }

    int status = index.data(PlaylistItemRoles::StatusRole).toInt();
    if(status != (int)PlaylistItemStatus::Finished){
        QLinearGradient gradientBackground(x, y, x, y+height);
        gradientBackground.setColorAt(0.0, bg1);
        gradientBackground.setColorAt(1.0, bg2);
        p->fillRect(r, gradientBackground);

        QLinearGradient gradientProgress(x, y, x, y+height);
        gradientProgress.setColorAt(0.0, QColor(0xFFCF3B6B));
        gradientProgress.setColorAt(1.0, QColor(0xFFAC073C));

        QRectF progressRect(x, y, width*progress, height);
        p->setBrush(gradientProgress);
        p->drawRect(progressRect);
    }


    // QFont f = p->font();
    f.setBold(true);
    p->setFont(f);
    p->setPen(Qt::white);

    p->drawText(r.adjusted(10,5,-80,-20), title);

    p->drawText(r.adjusted(-80,0,-10,0), Qt::AlignRight | Qt::AlignVCenter, msec2string(position));

    p->restore();
}
