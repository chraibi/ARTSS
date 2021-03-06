/// \file 		TurbulenceI.cpp
/// \brief 		Interface for Turbulence method
/// \date 		August 18, 2016
/// \author 	Suryanarayana Maddu
/// \copyright 	<2015-2020> Forschungszentrum Juelich GmbH. All rights reserved.

#ifndef ARTSS_INTERFACES_TURBULENCEI_H_
#define ARTSS_INTERFACES_TURBULENCEI_H_

#include "../Field.h"

class TurbulenceI {

public:
	TurbulenceI() = default;
	virtual ~TurbulenceI() = default;

	virtual void CalcTurbViscosity(Field* ev, Field* in_u, Field* in_v, Field* in_w, bool sync)=0;
	virtual void ExplicitFiltering(Field* out, const Field* in, bool sync)=0;
};

#endif /* ARTSS_INTERFACES_TURBULENCEI_H_ */
