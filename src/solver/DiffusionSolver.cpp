/// \file 		DiffusionSolver.h
/// \brief 		Defines the steps to solve the diffusion equation
/// \date 		May 20, 2016
/// \author 	Severt
/// \copyright 	<2015-2020> Forschungszentrum Juelich GmbH. All rights reserved.

#include <iostream>

#include "DiffusionSolver.h"
#include "../interfaces/DiffusionI.h"
#include "../utility/Parameters.h"
#include "../Domain.h"
#include "SolverSelection.h"

DiffusionSolver::DiffusionSolver() {

    auto params = Parameters::getInstance();
    std::string diffusionType = params->get("solver/diffusion/type");
    SolverSelection::SetDiffusionSolver(&this->dif, diffusionType);

    m_nu = params->getReal("physical_parameters/nu");
    control();
}

DiffusionSolver::~DiffusionSolver() {
    delete dif;
}

//====================================== DoStep =================================
// ***************************************************************************************
/// \brief  brings all calculation steps together into one function
/// \param	dt			time step
/// \param	sync		synchronous kernel launching (true, default: false)
// ***************************************************************************************
void DiffusionSolver::DoStep(real t, bool sync) {

#ifndef PROFILING
    std::cout << "Diffuse ..." << std::endl;
#endif
// 1. Solve diffusion equation
    // local variables and parameters for GPU
    auto u = SolverI::u;
    auto v = SolverI::v;
    auto w = SolverI::w;
    auto u0 = SolverI::u0;
    auto v0 = SolverI::v0;
    auto w0 = SolverI::w0;
    auto u_tmp = SolverI::u_tmp;
    auto v_tmp = SolverI::v_tmp;
    auto w_tmp = SolverI::w_tmp;

    auto d_u = u->data;
    auto d_v = v->data;
    auto d_w = w->data;
    auto d_u0 = u0->data;
    auto d_v0 = v0->data;
    auto d_w0 = w0->data;
    auto d_u_tmp = u_tmp->data;
    auto d_v_tmp = v_tmp->data;
    auto d_w_tmp = w_tmp->data;

    size_t bsize = Domain::getInstance()->GetSize(u->GetLevel());

#pragma acc data present(d_u[:bsize], d_u0[:bsize], d_u_tmp[:bsize], d_v[:bsize], d_v0[:bsize], d_v_tmp[:bsize], d_w[:bsize], d_w0[:bsize], d_w_tmp[:bsize])
    {
        dif->diffuse(u, u0, u_tmp, m_nu, sync);
        dif->diffuse(v, v0, v_tmp, m_nu, sync);
        dif->diffuse(w, w0, w_tmp, m_nu, sync);
    }//end data
}

//======================================= Check data ==================================
// ***************************************************************************************
/// \brief  Checks if field specified correctly
// ***************************************************************************************
void DiffusionSolver::control() {
    auto params = Parameters::getInstance();
    if (params->get("solver/diffusion/field") != "u,v,w") {
        std::cout << "Fields not specified correctly!" << std::endl;
        std::flush(std::cout);
        std::exit(1);
        //TODO Error handling + Loggers
    }
}
