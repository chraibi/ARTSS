//
// Created by linh on 01.10.19.
//

#include <iostream>
#include "Surface.h"
#include "../Domain.h"
#include "../utility/Utility.h"

//TODO duplicates ?
Surface::Surface(tinyxml2::XMLElement* element) {
    m_boundaryDataController = new BoundaryDataController();
    std::cout << "################ SURFACE ################" << std::endl;
    auto domain = Domain::getInstance();

    real dx = domain->Getdx();
    real dy = domain->Getdy();
    real dz = domain->Getdz();

    real rdx = 1./dx;
    real rdy = 1./dy;
    real rdz = 1./dz;

    real X1 = domain->GetX1();
    real Y1 = domain->GetX1();
    real Z1 = domain->GetX1();

    size_t Nx = domain->GetNx();
    size_t Ny = domain->GetNy();

    std::cout << "surface ID ";
    m_surfaceID = element->IntAttribute("ID");
    std::cout << m_surfaceID << std::endl;
    real sx1 = element->DoubleAttribute("sx1");
    real sx2 = element->DoubleAttribute("sx2");
    real sy1 = element->DoubleAttribute("sy1");
    real sy2 = element->DoubleAttribute("sy2");
    real sz1 = element->DoubleAttribute("sz1");
    real sz2 = element->DoubleAttribute("sz2");
    real lsx = fabs(sx2 - sx1);
    real lsy = fabs(sy2 - sy1);
    real lsz = fabs(sz2 - sz1);
    m_strideX = static_cast<size_t> (floor(lsx * rdx + 1 + 0.5));
    m_strideY = static_cast<size_t> (floor(lsy * rdy + 1 + 0.5));
    m_strideZ = static_cast<size_t> (floor(lsz * rdz + 1 + 0.5));
    //round due to cells at boundary (sx as midpoint of cells in xml)
    m_i1 = static_cast<size_t> (round(fabs(sx1 - (X1-0.5*dx)) * rdx));
    m_j1 = static_cast<size_t> (round(fabs(sy1 - (Y1-0.5*dy)) * rdy));
    m_k1 = static_cast<size_t> (round(fabs(sz1 - (Z1-0.5*dz)) * rdz));

    createSurface(Nx, Ny);
    print();
    std::cout << "----------------END SURFACE ----------------" << std::endl;
}

Surface::Surface(size_t surfaceID, size_t startIndex, size_t strideX, size_t strideY, size_t strideZ, size_t level) {
    std::cout << "################ SURFACE ################" << std::endl;
    std::cout << "LEVEL: " << level << std::endl;
    m_surfaceID = surfaceID;

    m_strideX = strideX;
    m_strideY = strideY;
    m_strideZ = strideZ;

    Domain* domain = Domain::getInstance();
    size_t Nx = domain->GetNx(level);
    size_t Ny = domain->GetNy(level);
    std::vector<size_t> coords = Utility::coordinateFromLinearIndex(startIndex, Nx, Ny);
    m_i1 = coords[0];
    m_j1 = coords[1];
    m_k1 = coords[2];

    init(Nx, Ny);
    std::cout << "----------------END SURFACE ----------------" << std::endl;
}

Surface::~Surface() {
    for (BoundaryData* bd: dataList){
        delete(bd);
    }
    delete(m_surfaceList);
}

void Surface::print(){
    size_t i2 = get_i2();
    size_t j2 = get_j2();
    size_t k2 = get_k2();
    std::cout << "Surface ID " << m_surfaceID << std::endl;
    std::cout << "strides: " << m_strideZ << " " << m_strideY <<  " " << m_strideX << std::endl;
    std::cout << "size of Surface: " << m_size_surfaceList << std::endl;
    std::cout << "coords: (" << m_i1 << "|" << i2 << ")(" << m_j1 << "|" << j2 << ")(" << m_k1 << "|" << k2 << std::endl;
}

void Surface::init(size_t Nx, size_t Ny){
    m_size_surfaceList = m_strideX * m_strideY * m_strideZ;
    m_surfaceList = new size_t[m_size_surfaceList];

    createSurface(Nx, Ny);
    print();
}

void Surface::createSurface(size_t Nx, size_t Ny){
    size_t counter = 0;
    std::cout << "list size of sList: " << m_size_surfaceList << std::endl;
    //fill sList with corresponding indices
    for (size_t k = m_k1; k < m_k1 + m_strideZ; ++k){
        for (size_t j = m_j1; j < m_j1 + m_strideY; ++j){
            for (size_t i = m_i1; i < m_i1 + m_strideX; ++i){
                size_t idx = (size_t)(IX(i,j,k,Nx,Ny));
                *(m_surfaceList + counter) = idx ;
                counter++;
            }
        }
    }
    std::cout << "control create Surface " << counter << "|" << m_size_surfaceList << std::endl;
    std::cout << "end of creating sList" << std::endl;
}

void Surface::setBoundaryConditions(tinyxml2::XMLElement *xmlElement) {
    m_boundaryDataController->addBoundaryData(xmlElement);
}

size_t Surface::get_i2() {
    return m_i1 + m_strideX - 1;
}
size_t Surface::get_j2() {
    return m_j1 + m_strideY - 1;
}
size_t Surface::get_k2(){
    return m_k1 + m_strideZ - 1;
}

void Surface::applyBoundaryConditions(real *dataField, FieldType fieldType, size_t level, bool sync){
    //TODO
    //m_bdc_boundary->applyBoundaryCondition(dataField, indexFields, patch_starts, patch_ends, fieldType, level, sync);
}
