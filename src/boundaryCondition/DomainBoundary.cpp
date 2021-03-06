/// \file 		DomainBoundary.cpp
/// \brief 		Applies boundary condition for domain boundary
/// \date 		Feb 03, 2020
/// \author 	My Linh Würzburger
/// \copyright 	<2015-2020> Forschungszentrum Juelich GmbH. All rights reserved.

#include "DomainBoundary.h"
#include "../Domain.h"

//======================================== Apply boundary condition ====================================
// ***************************************************************************************
/// \brief  Applies boundary condition for domain boundary
/// \param  dataField	Field
/// \param  indexFields List of indices for each patch
/// \param  patch_starts List of start indices
/// \param  patch_ends List of end indices
/// \param  level Multigrid level
/// \param  boundaryData Boundary data object of Domain
/// \param  sync synchronous kernel launching (true, default: false)
// ***************************************************************************************
void DomainBoundary::applyBoundaryCondition(real *dataField, size_t **indexFields, const size_t *patch_starts, const size_t *patch_ends, size_t level, BoundaryData *boundaryData, bool sync) {
    for (size_t i = 0; i < numberOfPatches; i++) {
        size_t *d_patch = *(indexFields + i);
        size_t patch_start = *(patch_starts + i);
        size_t patch_end = *(patch_ends + i);
        Patch p = static_cast<Patch>(i);
        switch (boundaryData->getBoundaryCondition(p)) {
            case BoundaryCondition::DIRICHLET:
                applyDirichlet(dataField, d_patch, p, patch_start, patch_end, level, boundaryData->getValue(p));
                break;
            case BoundaryCondition::NEUMANN:
                applyNeumann(dataField, d_patch, p, patch_start, patch_end, level, boundaryData->getValue(p));
                break;
            case BoundaryCondition::PERIODIC:
                applyPeriodic(dataField, d_patch, p, patch_start, patch_end, level);
                break;
        }
    }
    if (sync) {
#pragma acc wait
    }
}

//======================================== Apply boundary condition ====================================
// ***************************************************************************************
/// \brief  Set boundary condition for domain boundary
/// \param  dataField	Field
/// \param  d_patch List of indices for given patch
/// \param  patch_start Start Index of Patch
/// \param  patch_end End index of patch
/// \param  level Multigrid level
/// \param  referenceIndex Index of reference
/// \param  value Value of boundary condition
/// \param  sign Sign of boundary condition
// ***************************************************************************************
void DomainBoundary::applyBoundaryCondition(real *dataField, const size_t *d_patch, size_t patch_start, size_t patch_end, size_t level, int referenceIndex, real value, int8_t sign) {
    Domain *domain = Domain::getInstance();
    size_t bsize = domain->GetSize(level);
#pragma acc data present(dataField[:bsize])
    {
#pragma acc parallel loop independent present(d_patch[patch_start:(patch_end-patch_start)]) async
        for (size_t j = patch_start; j < patch_end; ++j) {
            const size_t index = d_patch[j];
            dataField[index] = sign * dataField[index + referenceIndex] + value;
        }
#pragma acc wait
    }
}

//======================================== Apply dirichlet ====================================
// ***************************************************************************************
/// \brief  Apply dirichlet boundary condition
/// \param  dataField	Field
/// \param  d_patch List of indices for given patch
/// \param  patch Patch
/// \param  patch_start Start Index of Patch
/// \param  patch_end End index of patch
/// \param  level Multigrid level
/// \param  value Value of boundary condition
// ***************************************************************************************
void DomainBoundary::applyDirichlet(real *dataField, size_t *d_patch, Patch patch, size_t patch_start, size_t patch_end, size_t level, real value) {
    if (level > 0) {
        value = 0;
    }
    Domain* domain = Domain::getInstance();
    int referenceIndex = 0;
    switch (patch){
        case BACK:
            referenceIndex = -domain->GetNx(level) * domain->GetNy(level);
            break;
        case FRONT:
            referenceIndex = domain->GetNx(level) * domain->GetNy(level);
            break;
        case TOP:
            referenceIndex = -domain->GetNx(level);
            break;
        case BOTTOM:
            referenceIndex = domain->GetNx(level);
            break;
        case RIGHT:
            referenceIndex = -1;
            break;
        case LEFT:
            referenceIndex = 1;
            break;
    }
    applyBoundaryCondition(dataField, d_patch, patch_start, patch_end, level, referenceIndex, value * 2, -1);
}

//======================================== Apply neumann ====================================
// ***************************************************************************************
/// \brief  Apply neumann boundary condition
/// \param  dataField	Field
/// \param  d_patch List of indices for given patch
/// \param  patch Patch
/// \param  patch_start Start Index of Patch
/// \param  patch_end End index of patch
/// \param  level Multigrid level
/// \param  value Value of boundary condition
// ***************************************************************************************
void DomainBoundary::applyNeumann(real *dataField, size_t *d_patch, Patch patch, size_t patch_start, size_t patch_end, size_t level, real value) {
    if (level > 0) {
        value = 0;
    }
    Domain* domain = Domain::getInstance();
    int referenceIndex = 0;
    switch (patch){
        case BACK:
            value *= domain->Getdz(level);
            referenceIndex = -domain->GetNx(level) * domain->GetNy(level);
            break;
        case FRONT:
            value *= domain->Getdz(level);
            referenceIndex = domain->GetNx(level) * domain->GetNy(level);
            break;
        case TOP:
            value *= domain->Getdy(level);
            referenceIndex = -domain->GetNx(level);
            break;
        case BOTTOM:
            value *= domain->Getdy(level);
            referenceIndex = domain->GetNx(level);
            break;
        case RIGHT:
            value *= domain->Getdz(level);
            referenceIndex = -1;
            break;
        case LEFT:
            value *= domain->Getdz(level);
            referenceIndex = 1;
            break;
    }
    applyBoundaryCondition(dataField, d_patch, patch_start, patch_end, level, referenceIndex, value, 1);
}

//======================================== Apply periodic ====================================
// ***************************************************************************************
/// \brief  Apply periodic boundary condition
/// \param  dataField	Field
/// \param  d_patch List of indices for given patch
/// \param  patch Patch
/// \param  patch_start Start Index of Patch
/// \param  patch_end End index of patch
/// \param  level Multigrid level
// ***************************************************************************************
void DomainBoundary::applyPeriodic(real *dataField, size_t *d_patch, Patch patch, size_t patch_start, size_t patch_end, size_t level) {
    Domain *domain = Domain::getInstance();
    size_t Nx = domain->GetNx(level);
    size_t Ny = domain->GetNy(level);

    int referenceIndex = 0;
    switch (patch){
        case FRONT:
            referenceIndex = Nx * Ny * (Domain::getInstance()->Getnz(level) - 2);
            break;
        case BACK:
            referenceIndex = -Nx * Ny * (Domain::getInstance()->Getnz(level) - 2);
            break;
        case BOTTOM:
            referenceIndex = Nx * (Domain::getInstance()->Getny(level) - 2);
            break;
        case TOP:
            referenceIndex = -Nx * (Domain::getInstance()->Getny(level) - 2);
            break;
        case LEFT:
            referenceIndex = (Domain::getInstance()->Getnx(level) - 2);
            break;
        case RIGHT:
            referenceIndex = -(Domain::getInstance()->Getnx(level) - 2);
            break;
    }
    applyBoundaryCondition(dataField, d_patch, patch_start, patch_end, level, referenceIndex, 0, 1);
}
