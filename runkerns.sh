#!/bin/bash

#SBATCH --job-name=dvs
#SBATCH --partition=batch
#SBATCH --gres=gpu:1
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=joshua.arnold1@uqconnect.edu.au

srun --gres=gpu:1 -n1 --exclusive matlab -nodisplay -r 'gpuEvolveKerns, exit'

wait
