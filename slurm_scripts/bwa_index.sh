#!/bin/bash -l

#### Use BWA to index fasta files.
########

#SBATCH -D /home/sbhadral/Projects/Rice_project/ref_gens/
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
#SBATCH --array=1

module load bwa/0.7.5a

FILE=$( sed -n "$SLURM_ARRAY_TASK_ID"p O_indica_index_list.txt )

bwa index -p O_indica "$FILE"