#ifndef PLAYLISTMODEL_H
#define PLAYLISTMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QVector>

#include <QMimeData>

#include "../models.h"

class PlaylistModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit PlaylistModel(QVector<PlaylistItem> *backendItems, QHash<QUuid, int> *backendMap, QObject *parent = nullptr);

    int rowCount(const QModelIndex&) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    void addItem(const PlaylistItem& item);
    int findByUuid(const QUuid& uuid);
    void updateTitle(const QUuid& uuid, const QString& title);
    void updatePosition(const QUuid& uuid, int ms);
    // void updateDuration(const QUuid& uuid, int ms);



    Qt::ItemFlags flags(const QModelIndex &index) const override;
    bool dropMimeData(const QMimeData *data, Qt::DropAction action, int row, int column, const QModelIndex &parent) override;

private:
    QVector<PlaylistItem> *items;
    QHash<QUuid, int> *uuidRowMap;

    bool canDropAt(int row, BlockType &outType) const;
};

#endif // PLAYLISTMODEL_H
