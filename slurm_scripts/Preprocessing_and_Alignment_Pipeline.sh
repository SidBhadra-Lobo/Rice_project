#!/bin/bash -l

#### Preprocessing and Alignment Pipeline (PAAP)
###### Cleaning up reads for alignment.
########

#SBATCH -D /home/sbhadral/Projects/Rice_project/
#SBATCH -J PAAP_test
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/%j.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/%j.err
#SBATCH -c 1
set -e
set -u

###### command line input. for file in $(ls *.gz); do sbatch /home/sbhadral/Projects/scripts/Preprocessing_and_Alignment_Pipeline.sh "$file" ; done


#### First, unzip .gz files, then sort reads using NGSUtils.

##module load zlib-1.2.8/

#file=$1 #$(ls /home/sbhadral/Projects/Rice_project/og_allo175/*.gz)
#file1=$(echo $file0 | sed -e 's/-R1\.fastq.gz/-R1.fastq/g' )
#file2=$(echo $file0 | sed -e 's/-R2\.fastq.gz/-R2.fastq/g' )
#echo $file0
#echo $file1
#echo $file2

for file in $(ls /home/sbhadral/Projects/Rice_project/og_allo175/*.gz);

do

gunzip -d -k -c -f < $file > /home/sbhadral/Projects/Rice_project/pre_alignment/

file1 = $(ls /home/sbhadral/Projects/Rice_project/pre_alignment/ | sed -e 's/-R1\.fastq/-R1/g')
file2 = $(ls /home/sbhadral/Projects/Rice_project/pre_alignment/ | sed -e 's/-R2\.fastq/-R2/g')

/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils properpairs -z /home/sbhadral/Projects/Rice_project/og_allo175/$file1 /home/sbhadral/Projects/Rice_project/og_allo175/$file2 

	 /home/sbhadral/Projects/Rice_project/pre_alignment/output1 /home/sbhadral/Projects/Rice_project/pre_alignment/output2 ;

done



###### Run reads through seqqs, which records metrics on read quality, length, base composition.

###### Trim adapter sequences off of reads using scythe.

###### Quality-based trimming with seqtk's trimfq.

###### Another around of seqqs, which records post pre-processing read quality metrics.

