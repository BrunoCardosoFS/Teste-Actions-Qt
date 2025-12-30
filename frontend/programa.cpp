#include "programa.h"
#include "./ui_programa.h"

Programa::Programa(QWidget *parent):QMainWindow(parent), ui(new Ui::Programa){
    ui->setupUi(this);

    QString version = QStringLiteral(APP_VERSION);
    this->setWindowTitle("Programa " + version);
}

Programa::~Programa()
{
    delete ui;
}
