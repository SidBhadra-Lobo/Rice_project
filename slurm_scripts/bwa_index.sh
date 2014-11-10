#!/bin/bash -l

#### 2DSFS from Arun's angsd-wrapper
########

#SBATCH -D /home/sbhadral/Projects/Rice_project/alignments/og_bams
#SBATCH -J index
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/%A_%a.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/%A_%a.err
#SBATCH -c 1
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u
#SBATCH --array=1-9

module load bwa/0.7.5a

FILE=$( sed -n "$SLURM_ARRAY_TASK_ID"p og_bams_list.txt )

bwa index "$FILE"