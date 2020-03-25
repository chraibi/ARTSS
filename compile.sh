#!/usr/bin/env bash
COMPILE=""
GPU=1
JURECA=1
P100=1
GPU_MODEL="K40"
BUILDTYPE=Release

YELLOW='\033[1;33m'
NC='\033[0;m'

DESCRIPTION="Script for compiling ARTSS. Select one or multiple executables for compiling (default: all executables). Specify CUDA version (default: $CUDA_VERSION) and GPU model (default: $GPU_MODEL). For a parallel execution choose --jobs, if there is no integer after the --jobs option, the number of processing units available to the current process will be used.
"
OPTIONS="
Available Options:

Load modules:
  ${YELLOW}--jureca${NC}                \t load modules for JURECA
  ${YELLOW}--p100${NC}                  \t load modules for P100

Executables:
  Production (with data output, visualization and analysis):
   ${YELLOW}-s${NC}
  ${YELLOW}--serial${NC} 
  ${YELLOW}--artss_serial${NC}        \t Executable: artss

  ${YELLOW} -m${NC}
  ${YELLOW}--multicore${NC}
  ${YELLOW}--artss_multicore_cpu${NC} \t Executable: artss_multicore_cpu

   ${YELLOW}-g${NC}
  ${YELLOW}--gpu${NC}
  ${YELLOW}--artss_gpu${NC}           \t Executable: artss_gpu
----  
  Benchmarking (without output, visualization, analysis but with tracing for profiling):
  ${YELLOW}--sp${NC}
  ${YELLOW}--serial_profile${NC}
  ${YELLOW}--artss_profile${NC}           \t Executable artss_serial_profile

  ${YELLOW}--mp${NC}
  ${YELLOW}--multicore_profile${NC}
  ${YELLOW}--artss_multicore_cpu_profile${NC} \t Executable artss_multicore_cpu_profile

  ${YELLOW}--gp${NC}
  ${YELLOW}--gpu_profile${NC}
  ${YELLOW}--artss_gpu_profile${NC}        \t Executable artss_gpu_profile

Other:
   ${YELLOW}-c${NC}
  ${YELLOW}--cudaversion${NC}             \t set CUDA Version
   ${YELLOW}-d${NC}
   ${YELLOW}--debugmode${NC}              \t set debug flag for build type (default: release)
  ${YELLOW}--gpumodel${NC}                \t set GPU model (K40, K80, P100)

  ${YELLOW}--jobs${NC}                    \t set the number of recipes to execute at once (-j/--jobs flag in make)

  ${YELLOW}--gcc${NC}                     \t use gcc as compiler (optional: specify version)
  ${YELLOW}--pgi${NC}                     \t use pgcc ac compiler (optional: specify version)
"

HELP="$DESCRIPTION$OPTIONS"
COMPILE=""
PROCS=-1
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --gp|--gpu_profile|--artss_gpu_profile)
      COMPILE="$COMPILE artss_gpu_profile "
      GPU=0
      shift
      ;;
    -c|--cuda)
      CUDA_VERSION="$2"
      shift
      shift
      ;;
    -d|--debug|--debugmode)
      BUILDTYPE=Debug 
      shift
      ;;
    -g|--gpu|--artss_gpu)
      COMPILE="$COMPILE artss_gpu" 
      GPU=0
      shift
      ;;
    --gcc)
      COMPILER="GCC"
      if [[ $2 != -* ]]
      then
        GCC_VERSION="$2"
        shift
      fi
      shift
      ;;
    --gpumodel)
      GPU_MODEL="$2"
      shift
      shift
      ;;
    -h|--help)
      echo -e "$HELP"
      exit
      ;;
    -j|--jobs)
      if [[ $2 =~ ^-?[0-9]+$ ]]
      then
        PROCS=$2
        shift
      else
        PROCS=$(nproc)
      fi
      shift
      ;;
    -m|--multicore|--artss_multicore_cpu)
      COMPILE="$COMPILE artss_multicore_cpu"
      GPU=0
      shift
      ;;
    --mp|--multicore_profile|--artss_multicore_cpu_profile)
      COMPILE="$COMPILE artss_multicore_cpu_profile"
      GPU=0
      shift
      ;;
    --pgi)
      COMPILER="PGI"
      if [[ $2 != -* ]]
      then
        PGI_VERSION="$2"
        shift
      fi
      shift
      ;;
    -s|--serial|--artss_serial)
      COMPILE="$COMPILE artss_serial"
      shift
      ;;
    --sp|--serial_profile|--artss_serial_profile)
      COMPILE="$COMPILE artss_serial_profile"
      shift
      ;;
    --jureca)
      JURECA=0
      shift
      ;;
    --p100)
      P100=0
      shift
      ;;
    *)
      POSITIONAL+=("$1")
      echo "unknown option: $1"
      shift
      ;;
  esac
done

if [[ $JURECA -eq 1 && $P100 -eq 1 ]]
then
  HOSTNAME=$(hostname)
  if [[ $HOSTNAME = jrl* ]]; then JURECA=0; fi
  if [ "$HOSTNAME" = "ias7139" ]; then P100=0; fi
fi

if [ "$COMPILE" = "" ]
then
  GPU=0
fi
if [ -z $COMPILER ]
then
  COMPILER="PGI"
fi

if [ $JURECA -eq 0 ]
then
  module use /usr/local/software/jureca/OtherStages
  module load Stages/2017a
  module load CMake/3.7.2
  module load PGI
  module load CUDA/8.0.61
  export CUDA_LIB=/usr/local/software/jureca/Stages/2017a/software/CUDA/8.0.61/lib64/
  export CUDA_INC=/usr/local/software/jureca/Stages/2017a/software/CUDA/8.0.61/include/
  CUDA_VERSION=8.0
  GPU_MODEL=K80
  GPU=0
fi

if [ ${P100} -eq 0 ]
then
  if [ -z "${PGI_VERSION}" ]
  then
    PGI_VERSION=19.4
  fi
  if [ -z ${CUDA_VERSION} ]
  then
    CUDA_VERSION=10.1
  fi
  if [ $GPU -eq 0 ]
  then
#    module load pgi/${PGI_VERSION}
#    module load cuda/${CUDA_VERSION}
    export CUDA_LIB=$CUDA_ROOT/lib64
    export CUDA_INC=$CUDA_ROOT/include
  fi
#  module list
  GPU_MODEL=P100
fi

rm -rf build/
mkdir build
cd build || exit

if [[ $GPU -eq 0 ]] || [[ $COMPILER = "PGI" ]]
then
  CCOMPILER=pgcc
  CXXCOMPILER=pgc++
else
  CCOMPILER=gcc
  CXXCOMPILER=g++
fi

if [ -z ${CUDA_VERSION} ]
then
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=${BUILDTYPE} -DCMAKE_C_COMPILER=${CCOMPILER} -DCMAKE_CXX_COMPILER=${CXXCOMPILER} ..
else
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=${BUILDTYPE} -DCMAKE_C_COMPILER=${CCOMPILER} -DCMAKE_CXX_COMPILER=${CXXCOMPILER} -DGPU_MODEL=${GPU_MODEL} -DCUDA_VERSION=${CUDA_VERSION} ..
fi

if [ "$PROCS" -le 0 ]
then
  make $COMPILE
else
  echo "-- Parallel execution with $PROCS processing units"
  make $COMPILE -j"$PROCS"
fi