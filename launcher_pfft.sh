#!/bin/bash -l

#SBATCH -J pfft

#SBATCH -A 2017-12-20

#SBATCH --time=01:00:58
#SBATCH --time-min=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --ntasks=8

#SBATCH --mail-type=FAIL
#SBATCH --mail-user=avmo@kth.se
#SBATCH -e SLURM.pfft.%J.stderr
#SBATCH -o SLURM.pfft.%J.stdout

echo "hostname: "$HOSTNAME


printf "\n# np=8 `date` PID $$ launcher_2018-02-07_19-44-00.sh SLURM.pfft.${SLURM_JOBID}.stdout\n./beskow_install_pfft.sh" >> SLURM_JOB.md
source /etc/profile
module load gcc/7.2.0
module swap PrgEnv-cray PrgEnv-intel
module swap intel intel/18.0.0.128
module add cdt/17.10 # add cdt module


./beskow_install_pfft.sh > SLURM.pfft.${SLURM_JOBID}.stdout 2>&1
