#!/bin/bash

#SBATCH --job-name=dvs
#SBATCH --output=slurm-job.out
#SBATCH --error=slurm.err
#SBATCH --partition=batch
#SBATCH --gres=gpu:1
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=joshua.arnold1@uqconnect.edu.au

srun matlab -nodisplay -r 'kernComGrow, exit'

wait
