/*=====================================================================*
 *                                                                     *
 *   Software Name : neu2fstr                                          *
 *         Version : 1.00                                              *
 *                                                                     *
 *     Last Update : 2006/06/01                                        *
 *        Category : FrontSTR Input File Converter                     *
 *                                                                     *
 *            Written by Noboru Imai (Univ. of Tokyo)                  *
 *                                                                     *
 *     Contact address :  IIS,The University of Tokyo RSS21 project    *
 *                                                                     *
 *     "Structural Analysis System for General-purpose Coupling        *
 *      Simulations Using Hight End Computing Middleware (HEC-MW)"     *
 *                                                                     *
 *=====================================================================*/

/*
	CFSTRDB_SFlux Ver.1.0
*/

#include "CFSTRDB.h"
#include "CHECData.h"

using namespace std;
using namespace hecd_util;



CFSTRDB_SFlux::CFSTRDB_SFlux()
 : CFSTRDataBlock(FSTRDB_SFLUX), ItemList()
{
	amp[0] = 0;
}


CFSTRDB_SFlux::~CFSTRDB_SFlux()
{
	Clear();
}


void CFSTRDB_SFlux::Clear()
{
	ItemList.clear();
	amp[0] = 0;
}


void CFSTRDB_SFlux::Write( CHECData* hecd )
{
	if( ItemList.size() == 0 ) return;

	if( amp[0] == 0 ) {
		hecd->WriteHeader( "!SFLUX" );
	} else {
		hecd->WriteHeader( "!SFLUX", "S", "AMP", amp );
	}

	vector<CItem>::iterator iter;
	for(iter = ItemList.begin(); iter != ItemList.end(); iter++){
		hecd->WriteData( "SF", iter->sgrp, iter->value);
	}
}



bool CFSTRDB_SFlux::Read( CHECData* hecd, char* header_line )
{
	int rcode[10];

	amp[0] = 0;
	if(!hecd->ParseHeader( header_line, rcode, "S", "AMP", amp )) return false;

	while(1) {
		CItem item;
		bool fg = hecd->ReadData( rcode, "SF", item.sgrp, &item.value );
		if( !fg ) break;
		ItemList.push_back( item );
	}
	return true;
}
