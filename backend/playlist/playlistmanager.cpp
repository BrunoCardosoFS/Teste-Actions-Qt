#include "playlistmanager.h"

PlaylistManager::PlaylistManager(QObject *parent):QObject{parent}{
    this->outputs[0]->setVolume(1);
    this->outputs[1]->setVolume(1);
    this->outputs[2]->setVolume(1);

    this->players[0]->setAudioOutput(this->outputs[0]);
    this->players[1]->setAudioOutput(this->outputs[1]);
    this->players[2]->setAudioOutput(this->outputs[2]);


    connect(this->timer, &QTimer::timeout, this, &PlaylistManager::timeout);

    timer->start(100);
}

void PlaylistManager::play(){
    if(this->status == PlaylistStatus::Playing || this->activePlayer < 0) return;

    players[activePlayer]->play();

    qInfo() << "Play" << activePlayer;
}

void PlaylistManager::pause(){
    qInfo() << "Pause";
}

void PlaylistManager::next(){
    qInfo() << "Next";
}

void PlaylistManager::stop(){
    qInfo() << "Stop";
}

int PlaylistManager::getNextPlayerIndex() const {
    return (this->activePlayer + 1) % 3;
}

void PlaylistManager::timeout(){
    int itemIndex = -1;
    for(int i=0; i <= items.size(); i++){
        if(items.at(i).status == PlaylistItemStatus::Default){
            itemIndex = i;
            break;
        }
    }

    if(players[getNextPlayerIndex()]->source() != QUrl(items[itemIndex].path)){
        qInfo() << "Carregou" << getNextPlayerIndex() << items[itemIndex].path;
        this->activePlayer = getNextPlayerIndex();
        players[getNextPlayerIndex()]->setSource(QUrl(items[itemIndex].path));
    }
}
