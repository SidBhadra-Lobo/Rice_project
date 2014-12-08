#!/bin/bash -l

#### 2DSFS from Arun's angsd-wrapper
########

#SBATCH -D /home/sbhadral/Projects/Rice_project/angsd-wrapper
#SBATCH -J 2DSFS
#SBATCH -p serial
#SBATCH -o /home/sbhadral/Projects/Rice_project/outs/%j.out
#SBATCH -e /home/sbhadral/Projects/Rice_project/errors/%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=sbhadralobo@ucdavis.edu
set -e
set -u


bash scripts/ANGSD_2DSFS_sid.sh scripts/2dsfs_ogs.conf
