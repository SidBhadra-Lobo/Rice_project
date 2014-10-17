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
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u

###### command line input. for file in $(ls *.gz); do sbatch /home/sbhadral/Projects/scripts/Preprocessing_and_Alignment_Pipeline.sh "$file" ; done


#### First, unzip .gz files, then sort reads using NGSUtils.

cd /home/sbhadral/Projects/Rice_project/test_dir/

# Initialize a list to run loop through.
for file1 in $(ls *R1*.gz);

do

## Replace file extensions accordingly for ease in processing.
file2=$(echo $file1 | sed -e 's/-R1\.fastq.gz/-R2.fastq.gz/g')
file3=$(echo $file1 | sed -e 's/-R1\.fastq.gz//g')

# Check that it's all cool with echos
echo $file1
echo $file2
echo $file3

## Sort each run, while directing tempfiles to a staging directory, then save as $file[1-2].sort
/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -T /home/sbhadral/Projects/Rice_project/pre_alignment <(gunzip -dkcf $file1)  > /home/sbhadral/Projects/Rice_project/pre_alignment/$file1.sort 

/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -T /home/sbhadral/Projects/Rice_project/pre_alignment <(gunzip -dkcf $file2) 	> /home/sbhadral/Projects/Rice_project/pre_alignment/$file2.sort


echo $file1.sort
echo $file2.sort

cd /home/sbhadral/Projects/Rice_project/pre_alignment/

#Find properly paired reads (when fragments are filtered separately).
/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils properpairs $file1.sort $file2.sort $file1.sort.pair $file2.sort.pair

echo $file1.sort.pair
echo $file2.sort.pair

# Merge the sorted runs into a single file.
/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils merge $file1.sort.pair $file2.sort.pair > $file3.sort.pair.merge 

# Check with echos
echo $file3.sort.pair.merge

###### Run reads through seqqs, which records metrics on read quality, length, base composition.


cat $file3.sort.pair.merge | /home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p raw-$(date +%F) >  /home/sbhadral/Projects/Rice_project/pre_alignment/$file3.sort.pair.merge.seqq

	echo $file3.sort.pair.merge.seqq

	cat $file3.sort.pair.merge.seqq | /home/sbhadral/Projects/Rice_project/seqtk/seqtk trimfq > /home/sbhadral/Projects/Rice_project/pre_alignment/$file3.sort.pair.merge.seqq.trimmed

			echo $file3.sort.pair.merge.trimmed
			
			cat $file3.sort.pair.merge.seqq.trimmed | /home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p raw-$(date +%F) > /home/sbhadral/Projects/Rice_project/pre_alignment/$file3.trimmed /home/sbhadral/Projects/Rice_project/pre_alignment/$file3.trimmed ;

done


###### Trim adapter sequences off of reads using scythe.

###### Quality-based trimming with seqtk's trimfq.

###### Another around of seqqs, which records post pre-processing read quality metrics.

