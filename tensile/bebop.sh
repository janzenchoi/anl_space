#!/bin/bash

#SBATCH --account=STARTUP-B324321
#SBATCH --partition=bdwall
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --time=03-00:00:00

source ~/.bashrc

NUM_PROCESSORS=32
DEER_PATH="$HOME/src/deer/deer-opt"
SIMULATION_FILE="input_simfile.i"
srun -n $NUM_PROCESSORS $DEER_PATH -i $SIMULATION_FILE
