/*
 ----------------------------------------------------------
|
| Software Name :conv2mw3 Ver 0.1 beta
|
|   Beam2.h
|
|                     Written by T.Takeda,    2012/06/01
|                                Y.Sato,      2012/06/01
|
|   Contact address : IIS, The University of Tokyo CISS
|
 ----------------------------------------------------------
*/
#ifndef FDBAD199_C996_45eb_8064_99466A8085B7
#define FDBAD199_C996_45eb_8064_99466A8085B7

#include "Element.h"

class CBeam2 : public CElement
{
public:
	CBeam2(void);
	virtual ~CBeam2(void);

	virtual size_t getNodeID_Fistr2MW3(size_t index);

	virtual size_t getNumOfFace(){return 0;}
	virtual size_t getNumOfEdge(){ return 1;}
	virtual const char* getCType(){ return "Beam2";}
	virtual size_t getNType(){ return FistrElementType::Beam2;}

	// Face
	virtual vector<CNode*> getFistrFaceNode(size_t nface){ vector<CNode*> vNode; return vNode;}
	virtual size_t getMW3FaceNum(size_t fistr_nface){ return 0;}

	virtual size_t getFaceNodeNum(size_t fistr_nface);
	virtual string getFaceType(size_t fistr_nface);

	// Edge
	virtual vector<CNode*> getFistrEdgeNode(size_t nedge);
	virtual string getEdgeType(size_t nedge);
	virtual size_t getMW3EdgeNum(size_t fistr_nedge);
};
#endif // include guard

