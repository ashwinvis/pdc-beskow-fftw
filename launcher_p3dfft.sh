#!/bin/bash -l

#SBATCH -J p3dfft

#SBATCH -A 2017-12-20

#SBATCH --time=01:00:58
#SBATCH --time-min=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --ntasks=8

#SBATCH --mail-type=FAIL
#SBATCH --mail-user=avmo@kth.se
#SBATCH -e SLURM.p3dfft.%J.stderr
#SBATCH -o SLURM.p3dfft.%J.stdout

echo "hostname: "$HOSTNAME


printf "\n# np=8 `date` PID $$ launcher_2018-02-07_19-43-51.sh SLURM.p3dfft.${SLURM_JOBID}.stdout\n./beskow_install_p3dfft.sh" >> SLURM_JOB.md

./beskow_install_p3dfft.sh > SLURM.p3dfft.${SLURM_JOBID}.stdout 2>&1
