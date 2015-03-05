/*
 ----------------------------------------------------------
|
| Software Name :conv2mw3 Ver 0.1 beta
|
|   Prism.h
|
|                     Written by T.Takeda,    2012/06/01
|                                Y.Sato,      2012/06/01
|
|   Contact address : IIS, The University of Tokyo CISS
|
 ----------------------------------------------------------
*/
#ifndef C452A922_15B1_4c36_AFE7_476AC6816DD1
#define C452A922_15B1_4c36_AFE7_476AC6816DD1

#include "Element.h"

class CPrism : public CElement
{
public:
	CPrism(void);
	virtual ~CPrism(void);

	virtual size_t getNodeID_Fistr2MW3(size_t index);

	virtual size_t getNumOfFace(){return 5;}
	virtual size_t getNumOfEdge(){ return 9;}
	virtual const char* getCType(){ return "Prism";}
	virtual size_t getNType(){ return FistrElementType::Prism;}

	// Face
	virtual vector<CNode*> getFistrFaceNode(size_t nface);
	virtual size_t getMW3FaceNum(size_t fistr_nface);

	virtual size_t getFaceNodeNum(size_t fistr_nface);
	virtual string getFaceType(size_t fistr_nface);

	// Edge
	virtual vector<CNode*> getFistrEdgeNode(size_t nedge);
	virtual string getEdgeType(size_t nedge);
	virtual size_t getMW3EdgeNum(size_t fistr_nedge);
};
#endif // include guard











