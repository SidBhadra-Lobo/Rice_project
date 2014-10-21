#!/bin/bash -l

#### Preprocessing and Alignment Pipeline (PAAP)
###### Cleaning up reads for alignment.
########

#SBATCH -D /home/sbhadral/Projects/Rice_project/rice_fastqs/
#SBATCH -J PAAP_og175
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/%j.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/%j.err
#SBATCH -c 1
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u
#SBATCH --array=1

module load bwa/0.7.5a

FILE=$( sed -n "$SLURM_ARRAY_TASK_ID"p /home/sbhadral/Projects/Rice_project/rice_fastqs/single_og175_test.txt )

## Before alignment, index reference. bwa index -p O_sativa Oryza_sativa.IRGSP-1.0.23.dna.genome.fa.gz


# Initialize a list to run loop through.
for file1 in "$FILE";

do

## Replace file extensions accordingly for ease in processing.
file2=$(echo $file1 | sed -e 's/-R1\.fastq.gz/-R2.fastq.gz/g')
file3=$(echo $file1 | sed -e 's/-R1\.fastq.gz//g')

# Check that it's all cool with echos
echo $file1
echo $file2
echo $file3

# make the directories to collect all files associated with each run.

mkdir $file3

###### First, unzip .gz files, then sort reads using NGSUtils. 
###### Sort each run, while directing temp files to a staging directory, then save as $file[1-2].sort

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -T /home/sbhadral/Projects/Rice_project/pre_alignment/ <(gunzip -dkc $file1) - > $file1.sort 

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -T /home/sbhadral/Projects/Rice_project/pre_alignment/ <(gunzip -dkc $file2) - > $file2.sort

	#### Trying to streamline it.
	#/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -T /home/sbhadral/Projects/Rice_project/pre_alignment <(gunzip -dkcf $file1) <(gunzip -dkcf $file2) |

		echo $file1.sort
		echo $file2.sort


#Find properly paired reads (when fragments are filtered separately).

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils properpairs  $file1.sort  $file2.sort $file1.sort.pair $file2.sort.pair

		echo $file1.sort.pair
		echo $file2.sort.pair

	#### Trying to streamline it.
	#/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils properpairs - > $file3.sort.pair

	#echo $file3.sort.pair

# Merge the sorted runs into a single file.

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils merge $file1.sort.pair $file2.sort.pair > $file3.sort.pair.merge 

		echo $file3.sort.pair.merge

###### Run reads through seqqs, which records metrics on read quality, length, base composition.

	cat $file3.sort.pair.merge | /home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p raw.$file3-$(date +%F) >  $file3.sort.pair.merge.seqq

		echo $file3.sort.pair.merge.seqq
	
	#### Trying to streamline it.

	#cat $file3.sort.pair | /home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils merge - > $file3.sort.pair.merge

	#echo $file3.sort.pair.merge

###### Trim adapter sequences off of reads using scythe.

 /home/sbhadral/Projects/Rice_project/scythe/scythe --quiet -a /home/sbhadral/Projects/Rice_project/scythe/illumina_adapters.fa $file3.sort.pair.merge.seqq > $file3.sort.pair.merge.seqq.scythe

	echo $file3.sort.pair.merge.seqq.scythe


	#### Trying to streamline it.
	
	#cat $file3.sort.pair.merge | /home/sbhadral/Projects/Rice_project/scythe/scythe --quiet -a /home/sbhadral/Projects/Rice_project/scythe/illumina_adapters.fa - |


###### Quality-based trimming with seqtk's trimfq.

		cat $file3.sort.pair.merge.seqq.scythe | /home/sbhadral/Projects/Rice_project/seqtk/seqtk trimfq -q 0.01 - > $file3.sort.pair.merge.seqq.scythe.trimmed
	
			mv raw.$file3-* /home/sbhadral/Projects/Rice_project/rice_fastqs/$file3/ 
			
				echo $file3.sort.pair.merge.seqq.scythe.trimmed

	#### Trying to streamline it.
	# /home/sbhadral/Projects/Rice_project/seqtk/seqtk trimfq -q 0.01 - |

###### Another around of seqqs, which records post pre-processing read quality metrics.			

				cat $file3.sort.pair.merge.seqq.scythe.trimmed | /home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p trimmed.$file3-$(date +%F) 
			
					> $file3.sort.pair.merge.seqq.scythe.trimmed.fq

							echo $file3.sort.pair.merge.seqq.scythe.trimmed.fq		

#### Trying to streamline it.
#/home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p trimmed.$file3-$(date +%F) - |

# mv trimmed.$file3-* /home/sbhadral/Projects/Rice_project/pre_alignment/$file3/

 

###### Align with BWA-MEM.

	bwa mem -M -t 1 -v 1 -p /home/sbhadral/Projects/Rice_project/ref_gens/O_sativa $file3.sort.pair.merge.seqq.scythe.trimmed.fq | 
	
		 samtools view -Sbhu - > /home/sbhadral/Projects/Rice_project/alignments/check.$file3.bam


mv *$file3*.sort* -f /home/sbhadral/Projects/Rice_project/rice_fastqs/$file3/ ;

done



