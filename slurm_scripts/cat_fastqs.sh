#!/bin/bash -l

#### Concatenating fastq runs into a full genome paired-end fastqs
########

#SBATCH -D /home/sbhadral/Projects/Rice_project/fixed_fastqs/
#SBATCH -J fastq_fix
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/%A_%a.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/%A_%a.err
#SBATCH -c 1
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u
##SBATCH --array=1-9

#FILE=$( sed -n "$SLURM_ARRAY_TASK_ID"p /home/sbhadral/Projects/Rice_project/fixed_fastqs/cat_list.txt )


for file in "FILE";

do 

file1=( echo $file | sed -e 's/R1\_001.fastq/R1*.fastq/g' )
file2=( echo $file1 |  sed -e 's/R1\*.fastq/R2*.fastq/g' )

echo $file1
echo $file2

cat $file1 | gzip -kc - > $file1.cat 

cat $file2 | gzip -kc - > $file2.cat ;

done

# EJF-001A_index1_ATCACG_L001_R1_001.fastq	 og273
# EJF-001B_index2_CGATGT_L001_R1_001.fastq	 og275
# EJF-001C_index3_TTAGGC_L001_R1_001.fastq	 og276
# EJF_002A_TGACCA_L007_R1_001.fastq		og278
# EJF_002B_ACAGTG_L007_R1_001.fastq 	og175
# EJF_002C_GCCAAT_L007_R1_001.fastq 	og176
# EJF_003A_CAGATC_L008_R1_001.fastq 	og177
# EJF_003B_ACTTGA_L008_R1_001.fastq 	og179
# EJF_003C_GATCAG_L008_R1_001.fastq 	bc1