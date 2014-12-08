#!/bin/bash -l

#### Showing flagstats of bams using samtools.

#SBATCH -D /home/sbhadral/Projects/Rice_project/alignments
#SBATCH -J flagstat_reseq_indica
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

FILE=$( sed -n "$SLURM_ARRAY_TASK_ID"p og_bam_list.txt )

samtools flagstat "$FILE" | sed -n -e 1p -e 3p  >> flagstats_og_indica.txt
