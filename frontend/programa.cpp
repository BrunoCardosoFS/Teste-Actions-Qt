#include "programa.h"
#include "./ui_programa.h"

#include "../backend/playlist/playlistmanager.h"
#include "../backend/playlist/playlistmodel.h"
#include "../backend/playlist/playlistdelegate.h"

#include "../backend/models.h"


Programa::Programa(QWidget *parent):QMainWindow(parent), ui(new Ui::Programa){
    ui->setupUi(this);

    QString version = QStringLiteral(APP_VERSION);
    this->setWindowTitle("Programa " + version);

    PlaylistManager* manager = new PlaylistManager(this);

    connect(this->ui->btnNext, &QPushButton::clicked, manager, &PlaylistManager::next);
    connect(this->ui->btnPlay, &QPushButton::clicked, manager, &PlaylistManager::play);
    connect(this->ui->btnPause, &QPushButton::clicked, manager, &PlaylistManager::pause);
    connect(this->ui->btnStop, &QPushButton::clicked, manager, &PlaylistManager::stop);

    PlaylistModel* model = new PlaylistModel(&manager->items, &manager->uuidRowMap, this);
    PlaylistDelegate* delegate = new PlaylistDelegate(this->ui->playlist);

    this->ui->playlist->setModel(model);
    this->ui->playlist->setItemDelegate(delegate);

    PlaylistItem block;
    block.uuid = QUuid::createUuid();
    block.title = "00:00";
    block.type = ItemType::BlockMarker;

    PlaylistItem commercialStart;
    commercialStart.uuid = QUuid::createUuid();
    commercialStart.type = ItemType::StartMarker;
    commercialStart.blockType = BlockType::Commercial;

    PlaylistItem commercialEnd;
    commercialEnd.uuid = QUuid::createUuid();
    commercialEnd.type = ItemType::EndMarker;
    commercialEnd.blockType = BlockType::Commercial;

    PlaylistItem musicalStart;
    musicalStart.uuid = QUuid::createUuid();
    musicalStart.type = ItemType::StartMarker;
    musicalStart.blockType = BlockType::Music;

    PlaylistItem musicalEnd;
    musicalEnd.uuid = QUuid::createUuid();
    musicalEnd.type = ItemType::EndMarker;
    musicalEnd.blockType = BlockType::Music;

    PlaylistItem itemComercial;
    itemComercial.uuid = QUuid::createUuid();
    itemComercial.title = "Título do Comercial.mp3";
    itemComercial.type = ItemType::Commercial;
    itemComercial.path = "D:/MEDIA/COMERCIAIS/Armazem Paraiba - Jingle padrao.wav";
    itemComercial.durationMs = 15000;
    itemComercial.positionMs = 3000;
    itemComercial.blockType = BlockType::Commercial;

    PlaylistItem itemJingleCommercial;
    itemJingleCommercial.uuid = QUuid::createUuid();
    itemJingleCommercial.title = "Título da Vinheta.mp3";
    itemJingleCommercial.type = ItemType::Jingle;
    itemJingleCommercial.path = "D:/MEDIA/VINHETAS/Jacobina FM/Passagem/ENCONTRO.mp3";
    itemJingleCommercial.durationMs = 6000;
    itemJingleCommercial.positionMs = 500;
    itemJingleCommercial.blockType = BlockType::Commercial;

    PlaylistItem itemMusica;
    itemMusica.uuid = QUuid::createUuid();
    itemMusica.title = "Título da Música.mp3";
    itemMusica.type = ItemType::Music;
    itemMusica.path = "D:/MEDIA/VINHETAS/Jacobina FM/Passagem/ENCONTRO.mp3";
    itemMusica.durationMs = 10000;
    itemMusica.positionMs = 5000;

    PlaylistItem itemJingle;
    itemJingle.uuid = QUuid::createUuid();
    itemJingle.title = "Título da Vinheta.mp3";
    itemJingle.type = ItemType::Jingle;
    itemJingle.path = "D:/MEDIA/VINHETAS/Jacobina FM/Passagem/ENCONTRO.mp3";
    itemJingle.durationMs = 6000;
    itemJingle.positionMs = 1000;

    itemMusica.status = PlaylistItemStatus::Finished;
    model->addItem(block);
    model->addItem(commercialStart);
    model->addItem(itemMusica);
    model->addItem(itemMusica);
    model->addItem(commercialEnd);
    model->addItem(musicalStart);
    itemMusica.status = PlaylistItemStatus::Playing;
    model->addItem(itemMusica);
    itemMusica.status = PlaylistItemStatus::Default;
    model->addItem(itemMusica);
    model->addItem(itemMusica);
    model->addItem(itemJingle);
    model->addItem(itemMusica);
    model->addItem(musicalEnd);


    QTime hour = QTime(0, 0);
    block.title = hour.toString("hh:mm");

    // for(int i=0; i<=50; i++){
    //     block.title = hour.addSecs(i*30*60).toString("hh:mm");

    //     model->addItem(block);
    //     model->addItem(commercialStart);
    //     model->addItem(itemComercial);
    //     model->addItem(itemJingleCommercial);
    //     model->addItem(itemComercial);
    //     model->addItem(commercialEnd);
    //     model->addItem(musicalStart);
    //     model->addItem(itemMusica);
    //     model->addItem(itemMusica);
    //     model->addItem(itemJingle);
    //     model->addItem(itemMusica);
    //     model->addItem(itemMusica);
    //     model->addItem(itemJingle);
    //     model->addItem(itemMusica);
    //     model->addItem(itemMusica);
    //     model->addItem(musicalEnd);
    // }
}

Programa::~Programa(){
    delete ui;
}
