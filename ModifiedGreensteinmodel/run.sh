#!/bin/bash
#SBATCH --mail-type=end
#SBATCH --partition=lrgmem
#SBATCH --nodes=1
##SBATCH --cpus-per-task=24
#SBATCH --ntasks-per-node=24
##SBATCH --mem=60GB
#SBATCH --time=48:00:00
#SBATCH --job-name=NormalAP

#Your model directory here
BASE_DIR=/scratch/users/qjin4@jhu.edu/Greenstein2002_rightLCC
BUILD_DIR=$BASE_DIR
EXEC=$BASE_DIR/stoch

module load gcc/6.4.0
#Place params.txt in WORK_DIR before running2; output will also be saved to WORK_DIR
WORK_DIR=$BASE_DIR

cd $WORK_DIR

echo Running job...
# export OMP_NUM_THREADS=$NPROCS
# export OMP_NUM_THREADS=8
# mpirun --mca btl openib,self -np 1 -hostfile host.list $EXEC
mpirun -np 24 $EXEC
~                                                                                                    
~                              
