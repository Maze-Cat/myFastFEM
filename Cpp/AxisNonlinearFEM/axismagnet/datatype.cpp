#include "datatype.h"

CMaterial::CMaterial()
    :Bdata(nullptr)
    ,Hdata(nullptr)
    ,BHpoints(0)
{
}

CMaterial::~CMaterial()
{

}

double CMaterial::getMu(double B)
{
    //���Բ���
    if(BHpoints == 0){
        return mu;
    }else{
        //ͨ����ֵ��������Բ���mu
    }
    return mu;
}

double CMaterial::getdvDb(double B)
{
    //��������Բ���dvdB

    return 0;
}
