#!/bin/bash -l

#### Preprocessing and Alignment Pipeline (PAAP)
###### Cleaning up reads for alignment.
########

#SBATCH -D /home/sbhadral/Projects/Rice_project/og_fastqs/test_og
#SBATCH -J PAAP_og_test
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/og_indica_test4_%A_%a.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/og_indica_test4_%A_%a.err
#SBATCH -c 1
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u
#SBATCH --array=1

module load bwa/0.7.5a

FILE=$( sed -n "$SLURM_ARRAY_TASK_ID"p test_align_list4.txt )

## Before alignment, index reference. bwa index -p O_* Oryza_*.IRGSP-1.0.23.dna.genome.fa.gz

# Initialize a list to run loop through.
for file1 in "$FILE";

do

## Replace file extensions accordingly for ease in processing.
file2=$(echo "$file1" | sed -e 's/_1\.fastq.gz/_2.fastq.gz/g')
file3=$(echo "$file1" | sed -e 's/_1\.fastq.gz//g')

# Check with echos
echo "$file1"
echo "$file2"
echo "$file3"

	
###### Sort each unzipped run, while directing temp files to a staging directory, then save as $file[1-2].sort

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -seq -T /home/sbhadral/Projects/Rice_project/pre_alignment <( gunzip -dc "$file1" ) > /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file1".sort
	
	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils sort -seq -T /home/sbhadral/Projects/Rice_project/pre_alignment <( gunzip -dc "$file2" ) > /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file2".sort

	echo sorted


###### Find properly paired reads (when fragments are filtered separately).

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils properpairs -f -t /home/sbhadral/Projects/Rice_project/pre_alignment/ /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file1".sort  /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file2".sort /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file1".sort.pair /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file2".sort.pair

	echo properpaired

####### Merge the sorted runs into a single file.

	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils merge -slash /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file1".sort.pair /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file2".sort.pair > /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file3".sort.pair.merge

	echo merged
	
####### EXPERIMENTAL STEP: fastqutils filter
##### -paired Only keep reads that are correctly paired (Requires an interleaved FASTQ file)
##### -discard filename Write the name of all discarded reads to a file.

#	/home/sbhadral/Projects/Rice_project/ngsutils/bin/fastqutils filter -discard /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/metrics/discards."$file3" -illumina -paired /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file3".sort.pair.merge - |

#	echo filtered

###### Run reads through seqqs, which records metrics on read quality, length, base composition.

	/home/sbhadral/Projects/Rice_project/seqqs/seqqs /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file3".sort.pair.merge -e  -i -p raw."$file3"-$(date +%F) - | 

	
	echo seqqs round 1

###### Trim adapter sequences off of reads using scythe.

 /home/sbhadral/Projects/Rice_project/scythe/scythe --quiet -a /home/sbhadral/Projects/Rice_project/scythe/illumina_adapters.fa - - |


	echo scythe adapter trimming


###### Quality-based trimming with seqtk's trimfq.

	/home/sbhadral/Projects/Rice_project/seqtk/seqtk trimfq - -q 0.01 - | # > /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file3".sort.pair.merge.seqq.scythe.trimmed
	 		
	echo seqtk quality-based trimming
	

###### Another around of seqqs, which records post pre-processing read quality metrics.			

	/home/sbhadral/Projects/Rice_project/seqqs/seqqs - -e -i -p trimmed."$file3"-$(date +%F) - | # > /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file3".sort.pair.merge.seqq.scythe.trimmed
	
	echo seqqs round 2


### make the directories to collect all files associated with each run.
## not necessary for resequenced, the directories are already made.	
	#
	#mkdir "$file3"


###### Align with BWA-MEM. -M Mark shorter split hits as secondary (for Picard compatibility). -t INT	Number of threads [1]. -v controls verbose; 1 for outputting errors only. -p Assume the first input query file is interleaved paired-end FASTA/Q. 

	bwa mem -M -t 1 -v 1 -p /group/jrigrp5/ECL298/ref_gens/Oryza_indica.ASM465v1.24.dna.genome.fa.gz - | # > "$file3".sam  # /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file3".sort.pair.merge.seqq.scythe.trimmed | 
	
		   samtools view -bSh  - > /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/test_bams/"$file3".bam

	echo alignment finished


mv raw."$file3"-* /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/metrics
mv trimmed."$file3"-* /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/metrics
rm -f /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file3"*.sort.* 
rm -f /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/"$file3"*.sort
# 
# 	samtools flagstat /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/test_bams/"$file3".bam > /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/flagstats/flagstat."$file3"
# 	
# 	samtools sort /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/test_bams/"$file3".bam /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/test_bams/"$file3".sorted
# 	
# 	samtools index /home/sbhadral/Projects/Rice_project/og_fastqs/test_og/test_bams/"$file3".sorted.bam;

	echo flagstat, sort, index finished

done



