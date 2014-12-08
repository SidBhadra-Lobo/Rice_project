#!/bin/bash -l

#### Preprocessing and Alignment Pipeline (PAAP)
###### Cleaning up reads for alignment.
########

#SBATCH -D /home/sbhadral/Projects/Rice_project/og_fastqs/
#SBATCH -J PAAP_og_indica
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

module load bwa/0.7.5a

FILE=$( sed -n "$SLURM_ARRAY_TASK_ID"p og_align_list.txt)

## Before alignment, index reference. bwa index -p O_sativa Oryza_sativa.IRGSP-1.0.23.dna.genome.fa.gz or Oryza_indica


# Initialize a list to run loop through.
for file1 in "$FILE";

do

## Replace file extensions accordingly for ease in processing.
file2=$(echo $file1 | sed -e 's/_1\.fastq.gz/_2.fastq.gz/g')
file3=$(echo $file1 | sed -e 's/_1\.fastq.gz//g')

# Check with echos
echo $file1
echo $file2
echo $file3

	
###### Sort each unzipped run, while directing temp files to a staging directory, then save as $file[1-2].sort

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -T /home/sbhadral/Projects/Rice_project/pre_alignment/ <( gunzip -dc $file1 ) > $file1.sort
	
	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -T /home/sbhadral/Projects/Rice_project/pre_alignment/ <( gunzip -dc $file2 ) > $file2.sort

	
	#### Trying to streamline it.
	#/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -T /home/sbhadral/Projects/Rice_project/pre_alignment <(gunzip -dkcf $file1) <(gunzip -dkcf $file2) |

		echo $file1.sort
		echo $file2.sort


###### Find properly paired reads (when fragments are filtered separately).

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils properpairs -t /home/sbhadral/Projects/Rice_project/pre_alignment/ $file1.sort  $file2.sort $file1.sort.pair $file2.sort.pair

		echo $file1.sort.pair
		echo $file2.sort.pair

	#### Trying to streamline it.
	#/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils properpairs - > $file3.sort.pair

	#echo $file3.sort.pair


####### Merge the sorted runs into a single file.

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils merge $file1.sort.pair $file2.sort.pair  - | #> $file3.sort.pair.merge 

		#echo $file3.sort.pair.merge



###### Run reads through seqqs, which records metrics on read quality, length, base composition.

	/home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p raw.$file3-$(date +%F) | #>  $file3.sort.pair.merge.seqq

		#echo $file3.sort.pair.merge.seqq
	
	

###### Trim adapter sequences off of reads using scythe.

 /home/sbhadral/Projects/Rice_project/scythe/scythe --quiet -a /home/sbhadral/Projects/Rice_project/scythe/illumina_adapters.fa - | #$file3.sort.pair.merge.seqq > $file3.sort.pair.merge.seqq.scythe

	#echo $file3.sort.pair.merge.seqq.scythe


	#### Trying to streamline it.
	
	#cat $file3.sort.pair.merge | /home/sbhadral/Projects/Rice_project/scythe/scythe --quiet -a /home/sbhadral/Projects/Rice_project/scythe/illumina_adapters.fa - |




###### Quality-based trimming with seqtk's trimfq.

	/home/sbhadral/Projects/Rice_project/seqtk/seqtk trimfq - -q 0.01 - > $file3.sort.pair.merge.seqq.scythe.trimmed
	 		
				echo $file3.sort.pair.merge.seqq.scythe.trimmed

	#### Trying to streamline it.
	# /home/sbhadral/Projects/Rice_project/seqtk/seqtk trimfq -q 0.01 - |




###### Another around of seqqs, which records post pre-processing read quality metrics.			

	/home/sbhadral/Projects/Rice_project/seqqs/seqqs $file3.sort.pair.merge.seqq.scythe.trimmed -e -i -p trimmed.$file3-$(date +%F) 
		

	# make the directories to collect all files associated with each run.

## not necessary for resequenced, the directories are already made.
	#
	#mkdir $file3

		mv raw.$file3-* /home/sbhadral/Projects/Rice_project/og_fastqs/$file3/ 

		mv trimmed.$file3-* /home/sbhadral/Projects/Rice_project/og_fastqs/$file3/


	#### Trying to streamline it.

	#/home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p trimmed.$file3-$(date +%F) - |

	# mv trimmed.$file3-* /home/sbhadral/Projects/Rice_project/pre_alignment/$file3/

 

###### Align with BWA-MEM.

	bwa mem -M -t 1  /home/sbhadral/Projects/Rice_project/ref_gens/O_indica $file3.sort.pair.merge.seqq.scythe.trimmed | 
	
		 samtools view -Sbhu - > /home/sbhadral/Projects/Rice_project/alignments/check.$file3.bam


mv *$file3*sort*  /home/sbhadral/Projects/Rice_project/og_fastqs/$file3/ ;


done



