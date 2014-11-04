#!/bin/bash -l

#### Preprocessing and Alignment Pipeline (PAAP) This time for resequenced japonica.
###### Cleaning up reads for alignment.
########

#!/bin/bash -l

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
#SBATCH --array=1

module load sratoolkit/2.3.2-4

## Download all the genomes from ncbi ftp site.
FILE=$( sed -n "$SLURM_ARRAY_TASK_ID"p accessions.txt )

for file in "$FILE";

do

# file1=$( grep -e "^ERS467" accessions.txt | sort -n )
# file2=$( grep -e "^ERS468" accessions.txt | sort -n )
# file3=$( grep -e "^ERS469" accessions.txt | sort -n )
# file4=$( grep -e "^ERS470" accessions.txt | sort -n )

echo $file
# echo $file1
# echo $file2
# echo $file3
# echo $file4

mkdir $file

wget -r -nc -A.sra -nd ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads//BySample/sra/ERS/ERS467/$file/
# 	wget -r -q -nc -A.sra ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads//BySample/sra/ERS/ERS468/$file2/
# 		wget -r -q -nc -A.sra ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads//BySample/sra/ERS/ERS469/$file3/
# 			wget -r -q -nc -A.sra ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads//BySample/sra/ERS/ERS470/$file4/

mv *.sra $file/
# 	mv ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/BySample/sra/ERS/ERS468/$file2/ERR*/*.sra 		/$file2/
# 		mv ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/BySample/sra/ERS/ERS469/$file3/ERR*/*.sra 		/$file3/
# 			mv ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/BySample/sra/ERS/ERS470/$file4/ERR*/*.sra 		/$file4/

cd $file

fastq-dump --split-files /home/sbhadral/Projects/Rice_project/reseq_japonica/$file/*.sra ; ## --outdir /home/sbhadral/Projects/Rice_project/reseq_japonica/$file/ ;

cat *_1.fastq > $file_1.fastq.gz

cat *_2.fastq > $file_2.fastq.gz

done;

## Make separate directories to organize separate sra's for fastq-dump then concatenation.

