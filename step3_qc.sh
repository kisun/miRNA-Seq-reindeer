#!/bin/bash -l
#SBATCH --job-name=step1_rmirna
#SBATCH --output=step3_err_out/out_stp3qc_%A_%a.txt
#SBATCH --error=step3_err_out/err_stp3qc_%A_%a.txt
#SBATCH --account=project_2000975
#SBATCH --partition=small
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --array=1-19
#SBATCH --mem-per-cpu=2000

module load biokit

myproj=/scratch/project_2000975/KISUN/projects/mirna/reindeer

cd ${myproj}/results/step3_trimmed/


sample=$(ls *.fastq | sed -n "$SLURM_ARRAY_TASK_ID"p)

echo "Analysing sample: $sample"
ls -l $sample

# Run FastQC
fastqc -o ${myproj}/results/step3_fastqc ${sample}

# Submit MultiQC job with dependency (only from first array task)
if [ "$SLURM_ARRAY_TASK_ID" -eq 1 ]; then
    # Count number of samples for array size
    num_samples=$(ls *.fastq | wc -l)
    
    # Submit MultiQC job dependent on this array job completion
    sbatch --dependency=afterok:${SLURM_ARRAY_JOB_ID} << EOF
#!/bin/bash -l
#SBATCH --job-name=step1_multiqc
#SBATCH --output=${myproj}/scripts/step3_err_out/multiqc_out_%j.txt
#SBATCH --error=${myproj}/scripts/step3_err_out/multiqc_err_%j.txt
#SBATCH --account=project_2000975
#SBATCH --partition=small
#SBATCH --time=00:05:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2000

module load tykky
export PATH="/projappl/project_2000975/bioinfotools/bin:\$PATH"



multiqc ${myproj}/results/step3_fastqc/ -o "${myproj}/results/step3_multiqc"
EOF
fi
