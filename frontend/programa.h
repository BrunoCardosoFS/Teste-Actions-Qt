#ifndef PROGRAMA_H
#define PROGRAMA_H

#include <QMainWindow>
#include <QMediaPlayer>
#include <QAudioOutput>

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

private slots:
    void on_pushButton_clicked();

private:
    Ui::Programa *ui;

    QMediaPlayer *player = new QMediaPlayer(this);
    QAudioOutput *audioOutput = new QAudioOutput(this);
};
#endif // PROGRAMA_H
