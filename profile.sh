#!/bin/bash
#SBATCH --job-name utk
#SBATCH --account=bckj-delta-cpu
#SBATCH --partition=cpu
#SBATCH --mem=16g
#SBATCH --cpus-per-task=1
#SBATCH --time 00:00:59
#SBATCH -e ./utk.e
#SBATCH -o ./utk.o

cd ~/HPC_BZAN583/
pwd

## module names can vary on different platforms
module load r
echo "loaded R"
module list

time Rscript profile.R
