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

cd /home/sbhadral/Projects/Rice_project/og_allo175/

for file1 in $(ls *R1*.gz);

do

file2=$(echo $file1 | sed -e 's/-R1\.fastq.gz/-R2.fastq.gz/g')
file3=$(echo $file1 | sed -e 's/-R1\.fastq.gz//g')

echo $file1
echo $file2
echo $file3

/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -T /home/sbhadral/Projects/Rice_project/pre_alignment <(gunzip -dkcf $file1) <(gunzip -dkcf $file2) > /home/sbhadral/Projects/Rice_project/pre_alignment/$file1.sort /home/sbhadral/Projects/Rice_project/pre_alignment/$file2.sort

echo $file1.sort
echo $file2.sort

cd /home/sbhadral/Projects/Rice_project/pre_alignment/

/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils merge $file1.sort $file2.sort > /home/sbhadral/Projects/Rice_project/pre_alignment/check.$file3.merge ;

echo check.$file3.merge

#gunzip -d -k -c -f < $file1 > ../pre_alignment/

#gunzip -d -k -c -f < $file2 > ../pre_alignment/

 ###sequtils <(gunzip file.gz) another option

#file1=$(echo $file | sed -e 's/-R1\.fastq.gz/-R1/g')

#/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils properpairs -z /home/sbhadral/Projects/Rice_project/pre_alignment/$file1 /home/sbhadral/Projects/Rice_project/pre_alignment/$file2
#
#			/home/sbhadral/Projects/Rice_project/pre_alignment/$file1.paired /home/sbhadral/Projects/Rice_project/pre_alignment/$file2.paired ;


#/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils properpairs -z <(gunzip -dkcf $file1) <(gunzip -dkcf $file2) 

#/home/sbhadral/Projects/Rice_project/og_allo175/$file1 /home/sbhadral/Projects/Rice_project/og_allo175/$file2 

# /home/sbhadral/Projects/Rice_project/pre_alignment/$file1.paired /home/sbhadral/Projects/Rice_project/pre_alignment/$file2.paired ;


done



###### Run reads through seqqs, which records metrics on read quality, length, base composition.

###### Trim adapter sequences off of reads using scythe.

###### Quality-based trimming with seqtk's trimfq.

###### Another around of seqqs, which records post pre-processing read quality metrics.

