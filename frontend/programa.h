#ifndef PROGRAMA_H
#define PROGRAMA_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui {
class Programa;
}
QT_END_NAMESPACE

class Programa : public QMainWindow
{
    Q_OBJECT

public:
    Programa(QWidget *parent = nullptr);
    ~Programa();

private:
    Ui::Programa *ui;
};
#endif // PROGRAMA_H
