/*
 ----------------------------------------------------------
|
| Software Name :HEC-MW Ver 4.4 beta
|
|   ./src/SolverCG.h
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
#ifndef SOLVERCG_H_
#define SOLVERCG_H_
#include "Solver.h"
namespace pmw
{
class CSolverCG: public pmw::CSolver
{
public:
    CSolverCG(iint iter_max, double tolerance,
              iint method, iint precondition,
              bool flag_iter, bool flag_time);
    virtual ~CSolverCG();
private:
//    uiint doSolve_(const CAssyMatrix *pA, const CAssyVector *pB, CAssyVector *pX,
//                    iint iter_max, double tolerance, bool flag_iter_log, bool flag_time_log);

    uiint doSolve( CAssyMatrix *pA, const CAssyVector *pB, CAssyVector *pX,
                   iint iter_max, double tolerance, bool flag_iter_log, bool flag_time_log);
};
}
#endif /* SOLVERCG_H_ */
