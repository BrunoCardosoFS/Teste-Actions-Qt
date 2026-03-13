#ifndef MODELS_H
#define MODELS_H

#include <QString>
#include <QList>
#include <QUuid>

enum class PlaylistStatus{
    Playing,
    Stopped,
    Paused,
};

enum class ItemType {
    Music,
    Commercial,
    Jingle,

    BlockMarker,
    StartMarker,
    EndMarker,
};

enum class BlockType {
    Music,
    Commercial
};

enum PlaylistItemStatus{
    Default,
    Playing,
    Finished,
};

enum PlaylistItemRoles{
    ToolTipRole = Qt::ToolTipRole,
    UuidRole,
    StatusRole,

    TitleRole,
    PathRole,

    DurationRole,
    PositionRole,

    MixStartRole,
    MixEndRole,

    BlockTypeRole,
    TypeRole
};

struct PlaylistItem {
    QUuid uuid;
    PlaylistItemStatus status = PlaylistItemStatus::Default;
    int playerId = -1;

    QString title;
    QString path;

    qint64 durationMs;
    qint64 positionMs = 0;

    qint64 mixStart;
    qint64 mixEnd;

    BlockType blockType;
    ItemType type = ItemType::Music;
};






#include <QPainterPath>
#include <QRectF>

inline QPainterPath roundedRect(const QRectF& r, qreal radiusTL, qreal radiusTR, qreal radiusBR, qreal radiusBL){
    QPainterPath path;

    path.moveTo(r.x() + radiusTL, r.y());

    path.lineTo(r.right() - radiusTR, r.y());
    if(radiusTR > 0)
        path.arcTo(QRectF(r.right() - 2*radiusTR, r.y(), 2*radiusTR, 2*radiusTR), 90, -90);

    path.lineTo(r.right(), r.bottom() - radiusBR);
    if(radiusBR > 0)
        path.arcTo(QRectF(r.right() - 2*radiusBR, r.bottom() - 2*radiusBR, 2*radiusBR, 2*radiusBR), 0, -90);

    path.lineTo(r.x() + radiusBL, r.bottom());
    if(radiusBL > 0)
        path.arcTo(QRectF(r.x(), r.bottom() - 2*radiusBL, 2*radiusBL, 2*radiusBL), 270, -90);

    path.lineTo(r.x(), r.y() + radiusTL);
    if(radiusTL > 0)
        path.arcTo(QRectF(r.x(), r.y(), 2*radiusTL, 2*radiusTL), 180, -90);

    path.closeSubpath();

    return path;
}

#include <QCoreApplication>
#include <QTime>

inline QString msec2string(qint64 msec){
    const QTime time = QTime(0, 0).addMSecs(msec);

    QString format = "mm:ss:zzz";
    if(msec >= 3600000){
        format = "hh:mm:ss";
    }

    return time.toString(format);
}

#endif // MODELS_H
