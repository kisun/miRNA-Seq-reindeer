#!/bin/bash -l
#SBATCH --job-name=step4_collapse
#SBATCH --output=step4_err_out/out_stp4_collapse_%A_%a.txt
#SBATCH --error=step4_err_out/err_stp4_collapse_%A_%a.txt
#SBATCH --account=project_2000975
#SBATCH --partition=small
#SBATCH --time=00:20:00
#SBATCH --ntasks=1
#SBATCH --array=1-19
#SBATCH --mem-per-cpu=4000

module load biokit

myproj=/scratch/project_2000975/KISUN/projects/mirna/reindeer
indir=/scratch/project_2000975/KISUN/projects/mirna/reindeer/results/step3_trimmed
outdir="${myproj}/results/step4_collapse"

mkdir -p "${myproj}/scripts/step4_err_out"
mkdir -p "${myproj}/results/step4_collapse"

cd $indir

# Select sample based on array task ID
sample=$(ls *.fasta | sed -n "$SLURM_ARRAY_TASK_ID"p)
filename="${sample%.fasta}"

echo "Collapsing sample: $sample"

# collapse reads: 
fastx_collapser -i "$sample" -o "$outdir/${filename}_collapsed.fasta" 


