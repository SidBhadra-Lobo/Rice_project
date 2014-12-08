#!/bin/bash -l

##########
## From alignment of meridionalis ref to O. sativa reference, use ANGSD to take meridionalis bam -> ancestral sequence
##########

#SBATCH -D /home/sbhadral/Projects/Rice_project/angsd-wrapper/angsd/
#SBATCH -J anc_ref
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/%j.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/%j.err
#SBATCH -c 1
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u

module load bwa/0.7.5a

## After alignment, use ANGSD to create new reference.

./angsd -i /home/sbhadral/Projects/Rice_project/alignments/check.SRR1528444.bam -doFasta 1 -out /home/sbhadral/Projects/Rice_project/ref_gens/Oryza_sativa -P 16

bwa index /home/sbhadral/Projects/Rice_project/ref_gens/Oryza_sativa.IRGSP-1.0.23.dna.genome.fa.gz
 