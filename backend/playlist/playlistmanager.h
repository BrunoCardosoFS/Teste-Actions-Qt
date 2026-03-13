#ifndef PLAYLISTMANAGER_H
#define PLAYLISTMANAGER_H

#include <QObject>
#include "../models.h"

#include <QMediaPlayer>
#include <QAudioOutput>
#include <QTimer>

class PlaylistManager : public QObject
{
    Q_OBJECT
public:
    explicit PlaylistManager(QObject *parent = nullptr);

    void play();
    void pause();
    void next();
    void stop();

    QVector<PlaylistItem> items;
    QHash<QUuid, int> uuidRowMap;

signals:

private:
    PlaylistStatus status = PlaylistStatus::Stopped;
    int activePlayer = -1;

    int getNextPlayerIndex() const;

    QList<QAudioOutput*> outputs = {new QAudioOutput(this), new QAudioOutput(this), new QAudioOutput(this)};
    QList<QMediaPlayer*> players = {new QMediaPlayer(this), new QMediaPlayer(this), new QMediaPlayer(this)};

    QTimer *timer = new QTimer(this);

private slots:
    void timeout();

};

#endif // PLAYLISTMANAGER_H
