#include "frontend/programa.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    Programa w;
    w.show();
    return a.exec();
}
