#!/bin/bash

#SBATCH --job-name=dvs
#SBATCH --output=slurm-job.out
#SBATCH --error=slurm.err
#SBATCH --partition=batch
#SBATCH --gres=gpu:2
#SBATCH --time=00:06:00


srun matlab -nodisplay -r 'kernComGrow, exit'

wait
