#!/bin/bash -l

##########
## From alignment of meridionalis ref to indica reference, use ANGSD to take meridionalis bam -> ancestral sequence
##########

#SBATCH -D /home/sbhadral/Projects/Rice_project/angsd-wrapper/angsd/
#SBATCH -J anc_ref_indica
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/ref_ref_%j.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/ref_ref_%j.err
#SBATCH -c 1
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u

module load bwa/0.7.5a

## After alignment, use ANGSD to create new reference.

./angsd -i /group/jrigrp5/ECL298/alignments/merid_indica_bam/check.SRR1528444.bam -rf /home/sbhadral/Projects/Rice_project/angsd-wrapper/data/wholeGenomeRegionFile.txt -doFasta 1 -out /home/sbhadral/Projects/Rice_project/ref_gens/Indica_merid -P 16

bwa index -p O_indica /group/jrigrp5/ECL298/ref_gens/Oryza_indica.ASM465v1.24.dna.genome.fa.gz
 