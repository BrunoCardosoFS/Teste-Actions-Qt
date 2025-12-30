#include "programa.h"
#include "./ui_programa.h"

Programa::Programa(QWidget *parent):QMainWindow(parent), ui(new Ui::Programa){
    ui->setupUi(this);

    this->player->setAudioOutput(this->audioOutput);
    this->audioOutput->setVolume(1);

    this->player->setSource(QUrl("qrc:/music/audios/Lady Gaga - Abracadabra.mp3"));

    QString version = QStringLiteral(APP_VERSION);
    this->setWindowTitle("Programa " + version);
}

Programa::~Programa()
{
    delete ui;
}

void Programa::on_pushButton_clicked(){
    if(this->player->isPlaying()){
        this->player->pause();
        return;
    }

    this->player->play();
}

