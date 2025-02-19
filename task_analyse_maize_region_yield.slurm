#!/bin/bash

#This task script expects to be called by another script which sets up the params_maize_analyse_region_yield.txt file and passes the correct --array parameter value

##SBATCH --time=10:01:00
###SBATCH --array=0-143%100		# 144 parallel tasks with a maximum of 100 running concurrently - commented out becasue we're passing it as a parameter from the calling script
#SBATCH --cpus-per-task=2		# Allocate 1 core per task
#SBATCH --job-name=price_analysis
#SBATCH --output=zlog-%x.%A_%a.out
##SBATCH --error=zlog-%x.%A_%a.err
###SBATCH --mail-user=zelingher@iiasa.ac.at
###SBATCH --mail-type=END,FAIL
#SBATCH --mem-per-cpu=4G


source /opt/apps/lmod/8.7/init/bash
module purge
module load R/4.3.2-gfbf-2023a


echo "I am job array task ID $SLURM_ARRAY_TASK_ID"

cd ~/price_forecasting

# Read the parameters for the current task
param_file="params_maize_analyse_region_yield.txt"
read pmonth lags script <<< $(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" $param_file)

# call model with this task's parameters
echo "pmonth=$pmonth" "lags=$lags" "source($script)"
Rscript -e "pmonth=$pmonth" -e "c='maize'" -e "lags=$lags" -e "source($script)"

