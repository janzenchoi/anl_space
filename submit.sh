#!/usr/bin/bash
#SBATCH -A CPCF 
#SBATCH -p bdwall
#SBATCH -N 1
#SBATCH --ntasks-per-node=36
#SBATCH -t 6:00:00

NPROC=36
BASEDIR=${PWD##*/}
ROOT=/lcrc/project/CPCF/709
DEER=$ROOT/packages/deer/deer-opt
COMMON=$ROOT/common

source $ROOT/profile

echo "Environment:"
echo "  ROOT=$ROOT"
echo "  BASEDIR=$BASEDIR"
echo "  DEER=$DEER"
echo "  COMMON=$COMMON"

CONFIG=(${BASEDIR//-/ })
MICRO=${CONFIG[0]} # 0-9
TC=${CONFIG[1]} # [600, 650, 700, 750, 800, 850, 900]
LOAD=${CONFIG[2]} # 0-4
GB=${CONFIG[3]} # 0-80, 100

echo "=============================="
echo "Current configuration:"
echo "  MICRO = $MICRO"
echo "  TC = $TC"
echo "  LOAD = $LOAD"
echo "  GB = $GB"

MESH_FILE=$COMMON/meshes/$MICRO/microstructure.e
TEXTURE_FILE=$COMMON/meshes/$MICRO/texture.csv
NEML_FILE=$COMMON/temperatures/$TC/model.xml

BASE_PARAMS=$COMMON/base.i
MICRO_PARAMS=$COMMON/meshes/$MICRO/params.i
TEMPERATURE_PARAMS=$COMMON/temperatures/$TC/params.i
LOAD_PARAMS=$COMMON/temperatures/$TC/loads/$LOAD/params.i
GB_PARAMS=$COMMON/GB/$GB/params.i
TERMINATION_PARAMS=$COMMON/termination.i

echo "=============================="
echo "Parameters:"
cat $MICRO_PARAMS
cat $TEMPERATURE_PARAMS
cat $LOAD_PARAMS
cat $GB_PARAMS

echo "=============================="
srun -n $NPROC $DEER -i $BASE_PARAMS \
$MICRO_PARAMS \
$TEMPERATURE_PARAMS \
$LOAD_PARAMS \
$GB_PARAMS \
$TERMINATION_PARAMS \
Mesh/fmg/file=$MESH_FILE \
UserObjects/EA/prop_file_name=$TEXTURE_FILE \
Materials/bulk/database=$NEML_FILE \
Outputs/file_base='out'
