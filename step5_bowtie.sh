#!/bin/bash -l
#SBATCH --job-name=step5_bwt
#SBATCH --output=step5_err_out/out_stp5_bwt_%A_%a.txt
#SBATCH --error=step5_err_out/err_stp5_bwt_%A_%a.txt
#SBATCH --account=project_2000975
#SBATCH --partition=small
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --array=1-19
#SBATCH --mem-per-cpu=24000

module load tykky
export PATH="/projappl/project_2000975/bioinfotools/bin:$PATH"

myproj=/scratch/project_2000975/KISUN/projects/mirna/reindeer
indir=/scratch/project_2000975/KISUN/projects/mirna/reindeer/results/step4_collapse
outdir="${myproj}/results/step5_align"
gidx="${myproj}/ref/rtarm"

# Create directories if they don't exist
mkdir -p "${myproj}/scripts/step5_err_out"
mkdir -p "${outdir}"

cd "$indir"

# Select sample based on array task ID
sample=$(ls *.fasta | sed -n "${SLURM_ARRAY_TASK_ID}p")

filename="${sample%_collapsed.fasta}"

echo "Aligning sample: $sample"

# Fixed bowtie command
bowtie -S -p 1 -v 2 -a -m 8 -f --best --strata \
    --al "${outdir}/${filename}.alignedReads.fa" \
    --un "${outdir}/${filename}.unalignedRead.fa" \
    "$gidx" "$sample" \
    "${outdir}/${filename}_aligned.sam"
