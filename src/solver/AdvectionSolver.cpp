/// \file 		AdvectionSolver.h
/// \brief 		Defines the steps to solve the advection equation
/// \date 		August 22, 2016
/// \author 	Severt
/// \copyright 	<2015-2020> Forschungszentrum Juelich GmbH. All rights reserved.

#include <iostream>

#include "AdvectionSolver.h"
#include "../interfaces/AdvectionI.h"
#include "../utility/Parameters.h"
#include "../Domain.h"
#include "SolverSelection.h"

AdvectionSolver::AdvectionSolver() {

    auto params = Parameters::getInstance();
    std::string advectionType = params->get("solver/advection/type");
    SolverSelection::SetAdvectionSolver(&adv, params->get("solver/advection/type"));

    real d_u_linm = params->getReal("initial_conditions/u_lin");
    real d_v_linm = params->getReal("initial_conditions/v_lin");
    real d_w_linm = params->getReal("initial_conditions/w_lin");

    u_linm = new Field(FieldType::U, d_u_linm);
    v_linm = new Field(FieldType::V, d_v_linm);
    w_linm = new Field(FieldType::W, d_w_linm);

    auto u_lin = u_linm;
    auto v_lin = v_linm;
    auto w_lin = w_linm;

    auto d_u_lin = u_lin->data;
    auto d_v_lin = v_lin->data;
    auto d_w_lin = w_lin->data;

    size_t bsize = Domain::getInstance()->GetSize(u_linm->GetLevel());

#pragma acc enter data copyin(d_u_lin[:bsize], d_v_lin[:bsize], d_w_lin[:bsize])
    control();
}

AdvectionSolver::~AdvectionSolver() {
    delete adv;

    auto d_u_lin = u_linm->data;
    auto d_v_lin = v_linm->data;
    auto d_w_lin = w_linm->data;

    size_t bsize = Domain::getInstance()->GetSize(u_linm->GetLevel());

#pragma acc exit data delete(d_u_lin[:bsize], d_v_lin[:bsize], d_w_lin[:bsize])

    delete u_linm;
    delete v_linm;
    delete w_linm;
}

//====================================== DoStep =================================
// ***************************************************************************************
/// \brief  brings all calculation steps together into one function
/// \param	dt			time step
/// \param	sync		synchronous kernel launching (true, default: false)
// ***************************************************************************************
void AdvectionSolver::DoStep(real t, bool sync) {
  // local variables and parameters for GPU
    auto u = SolverI::u;
    auto v = SolverI::v;
    auto w = SolverI::w;
    auto u0 = SolverI::u0;
    auto v0 = SolverI::v0;
    auto w0 = SolverI::w0;

    auto d_u = u->data;
    auto d_v = v->data;
    auto d_w = w->data;
    auto d_u0 = u0->data;
    auto d_v0 = v0->data;
    auto d_w0 = w0->data;

    auto u_lin = u_linm;
    auto v_lin = v_linm;
    auto w_lin = w_linm;

    auto d_u_lin = u_lin->data;
    auto d_v_lin = v_lin->data;
    auto d_w_lin = w_lin->data;

    size_t bsize = Domain::getInstance()->GetSize(u->GetLevel());

#pragma acc data present(d_u_lin[:bsize], d_v_lin[:bsize], d_w_lin[:bsize], d_u[:bsize], d_u0[:bsize], d_v[:bsize], d_v0[:bsize], d_w[:bsize], d_w0[:bsize])
    {
// 1. Solve advection equation
#ifndef PROFILING
        std::cout << "Advect ..." << std::endl;
        //TODO Logger
#endif
        adv->advect(u, u0, u_lin, v_lin, w_lin, sync);
        adv->advect(v, v0, u_lin, v_lin, w_lin, sync);
        adv->advect(w, w0, u_lin, v_lin, w_lin, sync);
    }//end data
}

//======================================= Check data ==================================
// ***************************************************************************************
/// \brief  Checks if field specified correctly
// ***************************************************************************************
void AdvectionSolver::control() {
    auto params = Parameters::getInstance();
    if (params->get("solver/advection/field") != "u,v,w") {
        std::cout << "Fields not specified correctly!" << std::endl;
        std::flush(std::cout);
        std::exit(1);
        //TODO Error handling + Logger
    }
}
