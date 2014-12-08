#!/bin/bash -l

#### SFS from Arun's angsd-wrapper
######## Testing this versus 2Dsfs.

#SBATCH -D /home/sbhadral/Projects/Rice_project/angsd-wrapper
#SBATCH -J SFS
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/%j.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u


bash scripts/ANGSD_SFS_sid.sh scripts/sfs_ogs.conf
