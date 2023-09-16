#!/bin/bash
##SBATCH --mail-type=end
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
##SBATCH --cpus-per-task=24
##SBATCH --mem=60GB
#SBATCH --time=24:00:00
#SBATCH --job-name=trans_23

#Your model directory here
BASE_DIR=/work/WinslowStorage/JHU_research/paper2/WalkerModel/testing/v2.2_LQTS
BUILD_DIR=$BASE_DIR
EXEC=$BASE_DIR/stoch3d
WORK_DIR=$BASE_DIR/output

cd $WORK_DIR

echo Running job...

export OMP_NUM_THREADS=24
$EXEC
~                                                                                                    
~                              
