/*
 ----------------------------------------------------------
|
| Software Name :HEC-MW Ver 4.4 beta
|
|   ./src/ContactMatrix.h
|
|                     Written by T.Takeda,    2013/03/26
|                                Y.Sato,      2013/03/26
|                                K.Goto,      2010/01/12
|                                K.Matsubara, 2010/06/01
|
|   Contact address : IIS, The University of Tokyo CISS
|
 ----------------------------------------------------------
*/
#ifndef CONTACTMATRIX_H_
#define CONTACTMATRIX_H_
namespace pmw
{
class CAssyVector;
class CContactMatrix
{
public:
    CContactMatrix();
    virtual ~CContactMatrix();
    void multVectorAdd(CAssyVector *pP, CAssyVector *pX);
};
}
#endif /* CONTACTMATRIX_H_ */
