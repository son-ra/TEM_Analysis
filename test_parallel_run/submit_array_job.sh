#!/bin/bash -l
  
# setting name of job
#SBATCH -J array_process_parallel

# setting home directory
#SBATCH -D /home/smmrrr/

# setting standard error output
#SBATCH -e /home/smmrrr/slurm_log/sterror_%j.txt

# setting standard output
#SBATCH -o /home/smmrrr/slurm_log/stdoutput_%j.txt
##SBATCH --array=0-1
# setting medium priority
#SBATCH -p high2

#SBATCH --nodes=1
#SBATCH --mem=100G
##SBATCH --ntasks=1
###SBATCH --cpus-per-task=1

# setting the max time
#SBATCH -t 10:00:00

# mail alerts at beginning and end of job
##SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END

# send mail here
#SBATCH --mail-user=srauschenbach@ucdavis.edu

# echo $SLURM_ARRAY_TASK_ID
loop_num=$1
srun /home/smmrrr/miniconda3/envs/condaforge/bin/python3.10 TEM_Analysis/TEM_Analysis/test_parallel_run/put_together_parallel.py $loop_num
