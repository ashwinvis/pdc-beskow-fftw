#!/bin/bash -l

#SBATCH -J fftw

#SBATCH -A 2017-12-20

#SBATCH --time=01:00:58
#SBATCH --time-min=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --ntasks=8

#SBATCH --mail-type=FAIL
#SBATCH --mail-user=avmo@kth.se
#SBATCH -e SLURM.fftw.%J.stderr
#SBATCH -o SLURM.fftw.%J.stdout

echo "hostname: "$HOSTNAME

printf "\n# np=8 `date` PID $$ launcher_fftw.sh SLURM.fftw.${SLURM_JOBID}.stdout\n./beskow_install_fftw.sh" >> SLURM_JOB.md

./beskow_install_fftw.sh > SLURM.fftw.${SLURM_JOBID}.stdout 2>&1
