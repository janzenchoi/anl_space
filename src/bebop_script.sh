#!/bin/bash

#SBATCH --account=STARTUP-CHOIH
#SBATCH --partition=bdws
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --time=01:00:00

source ~/.bashrc

NUM_PROCESSORS=8
DEER_PATH="$HOME/src/deer/deer-opt"
SIMULATION_FILE="simulation.i"
srun -n $NUM_PROCESSORS $DEER_PATH -i $SIMULATION_FILE
