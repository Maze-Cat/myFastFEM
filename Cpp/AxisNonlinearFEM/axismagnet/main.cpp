#include "mainwindow.h"
#include "axismagnet2d.h"
#include <QApplication>


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MainWindow w;
    w.show();

    AxisMagnet2D fem;
    fem.loadCOMSOLmeshfile("/Users/yuchenyang/Desktop/Final Thesis/myFastFEM/Cpp/AxisNonlinearFEM/axismagnet/model_normal.mphtxt");

    return a.exec();
}


