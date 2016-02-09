#!/bin/bash

#SBATCH --job-name=dvs
#SBATCH --output=slurm-job.out
#SBATCH --error=slurm.err
#SBATCH --partition=batch
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joshua.arnold1@uqconnect.edu.au

srun matlab -nodisplay -r 'kernComGrow, exit'

wait
