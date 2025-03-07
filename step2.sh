#!/bin/bash -l
#SBATCH --job-name=step2_rmirna
#SBATCH --output=step2_err_out/out_stp2_%A_%a.txt
#SBATCH --error=step2_err_out/err_stp2_%A_%a.txt
#SBATCH --account=project_2000975
#SBATCH --partition=small
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --array=1-19
#SBATCH --mem-per-cpu=4000

module load tykky
export PATH="/projappl/project_2000975/bioinfotools/bin:$PATH"

myproj="/scratch/project_2000975/KISUN/projects/mirna/reindeer"
adapt="/scratch/project_2000975/KISUN/projects/mirna/reindeer/scripts/adapters.fa"

cd "${myproj}/data/" || exit 1  # Exit if cd fails

# Create step2_err_out directory with -p to avoid errors if it exists
mkdir -p "${myproj}/scripts/step2_err_out"

# Create results/step2_flexbar directory and clean it if it exists
output_dir="${myproj}/results/step2_flexbar"
if [ -d "$output_dir" ]; then
    rm -rf "${output_dir}"/*
fi
mkdir -p "$output_dir"

# Select sample based on array task ID
sample=$(ls *.fastq.gz | sed -n "$SLURM_ARRAY_TASK_ID"p)
filename="${sample%.fastq.gz}"  # Changed %% to % to remove only .fastq.gz

# Check if sample is valid
if [ -z "$sample" ] || [ ! -f "$sample" ]; then
    echo "Error: No valid sample found for task $SLURM_ARRAY_TASK_ID"
    exit 1
fi

echo "Processing sample: $sample"

# Run flexbar with proper quoting
flexbar -r "$sample" -a "$adapt" -t "${output_dir}/${filename}_flexbar"