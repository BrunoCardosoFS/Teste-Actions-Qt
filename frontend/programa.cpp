#include "programa.h"
#include "./ui_programa.h"

Programa::Programa(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::Programa)
{
    ui->setupUi(this);
}

Programa::~Programa()
{
    delete ui;
}
