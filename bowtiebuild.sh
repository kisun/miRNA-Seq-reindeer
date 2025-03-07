#!/bin/bash -l
#SBATCH --job-name=bowtiebuild
#SBATCH --output=out_bowtiebuild.txt
#SBATCH --error=err_bowtiebuild.txt
#SBATCH --account=project_2000975
#SBATCH --partition=small
#SBATCH --time=6:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=40000

module load tykky
export PATH="/projappl/project_2000975/bioinfotools/bin:$PATH"

myproj="/scratch/project_2000975/KISUN/projects/mirna/reindeer"

cd "${myproj}/ref/" || exit 1  # Exit if cd fails




# Run bowtiebuild 
bowtie-build rtarm.fasta rtarm
