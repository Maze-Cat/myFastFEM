#include "axismagnet2d.h"
#include <QDebug>
#include <stdio.h>
#include <stdlib.h>

AxisMagnet2D::AxisMagnet2D()
{
    pnode = NULL;
    pelement = NULL;
    materialList = NULL;

}

AxisMagnet2D::~AxisMagnet2D()
{
    if(pnode != NULL) free(pnode);
    if(pelement != NULL) free(pelement);
    if(materialList != NULL) delete materialList;

}

bool AxisMagnet2D::loadCOMSOLmeshfile(const char fn[])
{
    char ch[256];
    //-------------open file-----------------

    FILE *fp = NULL;
    fp = fopen(fn,"r");
    if (fp == NULL) {
        qDebug() << "Error: openning file!";
        return -1;
    }

    //-------------jump first 18 lines--------

    for(int i=0;i<18;i++){
        fgets(ch,256,fp);
    }
    if(fscanf(fp,"%d # number of mesh points\n",&num_point) != 1){
        qDebug() << "Error:Can't read number of mesh points";
    }
    pnode =(CNode*)calloc(num_point, sizeof(CNode));
    int low_pt;
    if(fscanf(fp,"%d # lowest mesh point index\n",&low_pt) != 1){
        qDebug() << "Error:Can't read lowest mesh point index";
    }

    //-------------get mesh coordinates-------
    for(int i=low_pt;i<num_point;i++){
        if(fscanf(fp, "%lf %lf \n", &pnode[i].x, &pnode[i].y) != 2){
            qDebug() <<"Error:Can't read mesh coordinates";
        }

    }
    //-------------vertex---------------------

    for(int i=0;i<8;i++){
        fgets(ch,256,fp);
    }
    int vrt_ele;
    if(fscanf(fp,"%d # number of elements\n", &vrt_ele) != 1){
        qDebug() <<"Error:Can't read vertex";
    }
    for(int i=0;i<vrt_ele;i++){
        fgets(ch,256,fp);
    }

    //-------------vertex---------------------

    int vrt_ind;
    if(fscanf(fp,"%d # number of geometric entity indices\n", &vrt_ind) != 1){
        qDebug() <<"Error:Can't read vertex2";
    }

    for(int i=0;i<vrt_ind;i++){
        fgets(ch,256,fp);
    }

    //-------------edge-----------------------

    for(int i=0;i<6;i++){
        fgets(ch,256,fp);
    }

    int edg_ele;
    if(fscanf(fp,"%d # number of elements\n", &edg_ele) != 1){
        qDebug() <<"Error:Can't read edge";
    }
    for(int i=0;i<edg_ele;i++){
        fgets(ch,256,fp);
    }

    //-------------edge-----------------------

    int edg_ind;
    if(fscanf(fp,"%d # number of geometric entity indices\n", &edg_ind) != 1){
        qDebug() <<"Error:Can't read edge2";
    }

    for(int i=0;i<edg_ind;i++){
        fgets(ch,256,fp);
    }

    //-------------global number--------------

    for(int i=0;i<6;i++){
        fgets(ch,256,fp);
    }

    if(fscanf(fp,"%d # number of elements\n",&num_element) != 1){
        qDebug() << "Error:Can't read number of gllobal number";
    }
    pelement =(CElementT3*)calloc(num_element, sizeof(CElementT3));

    for(int i=0;i<num_element;i++){
        if(fscanf(fp, "%d %d %d \n", &pelement[i].n[0], &pelement[i].n[1], &pelement[i].n[2]) != 3){
            qDebug() <<"Error:Can't read mesh coordinates";
        }

    }
    //-------------domain---------------------

    int tri_ind;
    if(fscanf(fp,"%d # number of geometric entity indices\n",&tri_ind)){
        qDebug()<<"Error:Can't read domain";
    }

    for(int i=0;i<tri_ind;i++){
        if(fscanf(fp,"%d",&pelement[i].domain) != 1){
            qDebug()<<"Error:Can't read domain2";
        }
    }
    //------------close file------------------
    fclose(fp);
    fp = NULL;
    return 0;


}

bool AxisMagnet2D::NewtonSolve()
{

    return true;
}
