/*
 ----------------------------------------------------------
|
| Software Name :HEC-MW Ver 4.4 beta
|
|   ./src/DeleteObject.h
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
namespace pmw
{
struct DeleteObject {
    template<typename T>
    void operator()(const T* ptr) const {
        delete ptr;
    }
};
}
