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

mkdir $file3

## somethings going on here, but not enough battery power left to check it just yet. Saying /$file3/$file3.sort.pair.merge.seqq doesn't exist but the output is there...
cat $file3.sort.pair.merge | /home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p raw.$file3-$(date +%F) >  /home/sbhadral/Projects/Rice_project/pre_alignment/$file3.sort.pair.merge.seqq

	echo $file3.sort.pair.merge.seqq
	

###### Trim adapter sequences off of reads using scythe.

 /home/sbhadral/Projects/Rice_project/scythe/scythe --quiet -a /home/sbhadral/Projects/Rice_project/scythe/illumina_adapters.fa $file3.sort.pair.merge.seqq > $file3.sort.pair.merge.seqq.scythe

	echo $file3.sort.pair.merge.seqq.scythe

###### Quality-based trimming with seqtk's trimfq.

	cat $file3.sort.pair.merge.seqq.scythe | /home/sbhadral/Projects/Rice_project/seqtk/seqtk trimfq -q 0.01 - > /home/sbhadral/Projects/Rice_project/pre_alignment/$file3.sort.pair.merge.seqq.scythe.trimmed
	
mv raw.$file3-* /home/sbhadral/Projects/Rice_project/pre_alignment/$file3/ 
			
			echo $file3.sort.pair.merge.seqq.scythe.trimmed
			
			cat $file3.sort.pair.merge.seqq.scythe.trimmed | /home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p trimmed.$file3-$(date +%F) 
			
				> /home/sbhadral/Projects/Rice_project/pre_alignment/$file3.sort.pair.merge.seqq.scythe.trimmed.out

		echo $file3.sort.pair.merge.seqq.scythe.trimmed.out		

mv trimmed.$file3-* /home/sbhadral/Projects/Rice_project/pre_alignment/$file3/

mv *$file3*.sort* -f /home/sbhadral/Projects/Rice_project/pre_alignment/$file3/ ;

done




###### Another around of seqqs, which records post pre-processing read quality metrics.

