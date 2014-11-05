#!/bin/bash -l

#### Preprocessing and Alignment Pipeline (PAAP) This time for resequenced japonica.
###### Cleaning up reads for alignment.
########

#SBATCH -D /home/sbhadral/Projects/Rice_project/reseq_japonica
#SBATCH -J reseq_fastqdump
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/%A_%a.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/%A_%a.err
#SBATCH -c 1
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u
#SBATCH --array=1-3

module load sratoolkit/2.3.2-4

## Download all the genomes from ncbi ftp site.
FILE=$( sed -n "$SLURM_ARRAY_TASK_ID"p accessions.txt )

for file in "$FILE";

do

# file1=$( grep -e "^ERS467" accessions.txt | sort -n )
# file2=$( grep -e "^ERS468" accessions.txt | sort -n )
# file3=$( grep -e "^ERS469" accessions.txt | sort -n )
# file4=$( grep -e "^ERS470" accessions.txt | sort -n )

echo "$file"
# echo $file1
# echo $file2
# echo $file3
# echo $file4

## Make separate directories to organize separate sra's for fastq-dump then concatenation.
mkdir "$file"

cd "$file"

wget -r -A.sra -nd ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads//BySample/sra/ERS/ERS470/"$file"/
#468443 468337 redo, couldn't log into ncbi ftp site.

# then do 467 (4 files), 468 (26 files), 469 (2 files) , 470 (3 files) change arrays size to fit number of files.

# 	mv ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/BySample/sra/ERS/ERS468/$file2/ERR*/*.sra 		/$file2/
# 		mv ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/BySample/sra/ERS/ERS469/$file3/ERR*/*.sra 		/$file3/
# 			mv ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/BySample/sra/ERS/ERS470/$file4/ERR*/*.sra 		/$file4/

fastq-dump --split-files /home/sbhadral/Projects/Rice_project/reseq_japonica/"$file"/*.sra ; ## --outdir /home/sbhadral/Projects/Rice_project/reseq_japonica/$file/ ;

cat *_1.fastq | gzip -kc > "$file"_1.fastq.gz

cat *_2.fastq | gzip -kc > "$file"_2.fastq.gz

rm *.sra
rm *.fastq

done;



