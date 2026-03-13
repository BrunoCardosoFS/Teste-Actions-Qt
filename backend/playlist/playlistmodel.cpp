#include "playlistmodel.h"

#include <QDataStream>
#include <QIODevice>


PlaylistModel::PlaylistModel(QVector<PlaylistItem> *backendItems, QHash<QUuid, int> *backendMap, QObject *parent)
    : QAbstractListModel(parent), items(backendItems), uuidRowMap(backendMap) {}

int PlaylistModel::rowCount(const QModelIndex&) const{
    return this->items->size();
}

QVariant PlaylistModel::data(const QModelIndex& index, int role) const{
    if (!items || !index.isValid() || index.row() >= items->size())
        return QVariant();

    const PlaylistItem item = items->at(index.row());

    switch(role){
        case PlaylistItemRoles::ToolTipRole: return item.title;
        case PlaylistItemRoles::UuidRole: return item.uuid;
        case PlaylistItemRoles::StatusRole: return item.status;
        case PlaylistItemRoles::TitleRole: return item.title;
        case PlaylistItemRoles::PathRole: return item.path;
        case PlaylistItemRoles::DurationRole: return item.durationMs;
        case PlaylistItemRoles::PositionRole: return item.positionMs;
        case PlaylistItemRoles::MixStartRole: return item.mixStart;
        case PlaylistItemRoles::MixEndRole: return item.mixEnd;
        case PlaylistItemRoles::BlockTypeRole: return (int)item.blockType;
        case PlaylistItemRoles::TypeRole: return (int)item.type;
    }

    return {};
}

void PlaylistModel::addItem(const PlaylistItem& item){
    beginInsertRows({}, items->size(), items->size());
    items->push_back(item);
    (*uuidRowMap)[item.uuid] = items->size() - 1;
    endInsertRows();
}

int PlaylistModel::findByUuid(const QUuid& uuid){
    if(!uuidRowMap->contains(uuid))
        return -1;

    return (*uuidRowMap)[uuid];
}

void PlaylistModel::updateTitle(const QUuid& uuid, const QString& title){
    int row = findByUuid(uuid);
    if(row < 0) return;

    (*items)[row].title = title;

    QModelIndex idx = index(row, 0);
    emit dataChanged(idx, idx, {PlaylistItemRoles::TitleRole});
}

void PlaylistModel::updatePosition(const QUuid& uuid, int ms){
    int row = findByUuid(uuid);
    if(row < 0) return;

    (*items)[row].positionMs = ms;

    QModelIndex idx = index(row, 0);
    emit dataChanged(idx, idx, {PlaylistItemRoles::PositionRole});
}

// void PlaylistModel::updateDuration(const QUuid& uuid, int ms){

// }


Qt::ItemFlags PlaylistModel::flags(const QModelIndex &index) const {
    auto defaultFlags = QAbstractListModel::flags(index);
    if (index.isValid()) {
        ItemType type = (ItemType)items->at(index.row()).type;
        PlaylistItemStatus status = (PlaylistItemStatus)items->at(index.row()).status;

        if (type != ItemType::BlockMarker && type != ItemType::StartMarker && type != ItemType::EndMarker && status == PlaylistItemStatus::Default) {
            return defaultFlags | Qt::ItemIsDragEnabled;
        }
        return defaultFlags;
    }
    return defaultFlags | Qt::ItemIsDropEnabled;
}


bool PlaylistModel::canDropAt(int row, BlockType &outType) const {
    if (row < 0) return false;
    if(row < items->size() && items->at(row).status != PlaylistItemStatus::Default) return false;

    if (row == 0){
        ItemType itemBelowType = items->at(row).type;

        if(itemBelowType == ItemType::EndMarker || itemBelowType == ItemType::Commercial || itemBelowType == ItemType::Music || itemBelowType == ItemType::Jingle){
            outType = items->at(row).blockType;
            return true;
        }else{
            return false;
        }
    }

    ItemType itemAboveType = items->at(row - 1).type;

    if (itemAboveType == ItemType::StartMarker || itemAboveType == ItemType::Commercial || itemAboveType == ItemType::Music || itemAboveType == ItemType::Jingle){
        outType = items->at(row - 1).blockType;
        return true;
    }
    return false;
}

bool PlaylistModel::dropMimeData(const QMimeData *data, Qt::DropAction action, int row, int column, const QModelIndex &parent) {
    if (action == Qt::IgnoreAction) return true;
    if (!data->hasFormat("application/x-qabstractitemmodeldatalist")) return false;

    int beginRow = row;
    if (row == -1) beginRow = parent.isValid() ? parent.row() : rowCount({});

    BlockType targetBlockType;
    if (!canDropAt(beginRow, targetBlockType)) return false;

    QByteArray encodedData = data->data("application/x-qabstractitemmodeldatalist");
    QDataStream stream(&encodedData, QIODevice::ReadOnly);
    int sourceRow, sourceCol;
    QMap<int, QVariant> roleDataMap;
    stream >> sourceRow >> sourceCol >> roleDataMap;

    if (sourceRow == beginRow || sourceRow == beginRow - 1) return false;


    int destinationRow = beginRow;
    if (sourceRow < beginRow) destinationRow--;

    if (beginMoveRows(QModelIndex(), sourceRow, sourceRow, QModelIndex(), beginRow)) {
        PlaylistItem movedItem = items->takeAt(sourceRow);

        movedItem.blockType = targetBlockType;
        items->insert(destinationRow, movedItem);

        uuidRowMap->clear();
        for (int i = 0; i < items->size(); ++i) {
            (*uuidRowMap)[items->at(i).uuid] = i;
        }

        endMoveRows();
        return true;
    }

    return false;
}






