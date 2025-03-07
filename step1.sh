#!/bin/bash -l
#SBATCH --job-name=step1_rmirna
#SBATCH --output=step1_err_out/out_stp1_%A_%a.txt
#SBATCH --error=step1_err_out/err_stp1_%A_%a.txt
#SBATCH --account=project_2000975
#SBATCH --partition=small
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --array=1-19
#SBATCH --mem-per-cpu=2000

module load biokit

myproj=/scratch/project_2000975/KISUN/projects/mirna/reindeer

cd ${myproj}/data/

# Create step1_err_out directory in current directory if it doesn't exist
mkdir -p ../step1_err_out

# Create results/step1_fastqc directory and clean it if it exists
output_dir="${myproj}/results/step1_fastqc"
if [ -d "$output_dir" ]; then
    rm -rf "$output_dir"/*  # Remove existing files in the directory
fi
mkdir -p "$output_dir"  # Create the directory if it doesn't exist

sample=$(ls *.fastq.gz | sed -n "$SLURM_ARRAY_TASK_ID"p)

echo "Analysing sample: $sample"
ls -l $sample

# Run FastQC
fastqc -o ${myproj}/results/step1_fastqc ${sample}

# Submit MultiQC job with dependency (only from first array task)
if [ "$SLURM_ARRAY_TASK_ID" -eq 1 ]; then
    # Count number of samples for array size
    num_samples=$(ls *.fastq.gz | wc -l)
    
    # Submit MultiQC job dependent on this array job completion
    sbatch --dependency=afterok:${SLURM_ARRAY_JOB_ID} << EOF
#!/bin/bash -l
#SBATCH --job-name=step1_multiqc
#SBATCH --output=${myproj}/scripts/step1_err_out/multiqc_out_%j.txt
#SBATCH --error=${myproj}/scripts/step1_err_out/multiqc_err_%j.txt
#SBATCH --account=project_2000975
#SBATCH --partition=small
#SBATCH --time=00:05:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2000

module load tykky
export PATH="/projappl/project_2000975/bioinfotools/bin:\$PATH"

# Create and clean MultiQC output directory named step1_multiqc under results
if [ -d "${myproj}/results/step1_multiqc" ]; then
    rm -rf "${myproj}/results/step1_multiqc"/*
fi
mkdir -p "${myproj}/results/step1_multiqc"

multiqc ${myproj}/results/step1_fastqc/ -o "${myproj}/results/step1_multiqc"
EOF
fi
