#!/bin/bash -l
#SBATCH --job-name=step3_cutadapt
#SBATCH --output=step3_err_out/out_stp3_cutadapt_%A_%a.txt
#SBATCH --error=step3_err_out/err_stp3_cutadapt_%A_%a.txt
#SBATCH --account=project_2000975
#SBATCH --partition=small
#SBATCH --time=00:20:00
#SBATCH --ntasks=1
#SBATCH --array=1-19
#SBATCH --mem-per-cpu=4000

module load tykky
export PATH="/projappl/project_2000975/bioinfotools/bin:$PATH"

myproj=/scratch/project_2000975/KISUN/projects/mirna/reindeer
indir=/scratch/project_2000975/KISUN/projects/mirna/reindeer/results/step2_flexbar
trimdir="${myproj}/results/step3_trimmed"

cd $indir

# Select sample based on array task ID
sample=$(ls *.fastq | sed -n "$SLURM_ARRAY_TASK_ID"p)
filename="${sample%_flexbar.fastq}"

echo "Trimming sample: $sample"

# Trim reads: min 18bp, max 28bp
cutadapt -m 18 -q 20 -l 28 -o "$trimdir/${filename}_trimmed.fastq" "$sample"


