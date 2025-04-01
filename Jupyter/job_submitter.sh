#!/bin/bash
#SBATCH --job-name=OmF_sum
#SBATCH -o output.%j
#SBATCH -e error.%j
#SBATCH --ntasks=10
#SBATCH --time=00:15:00
#SBATCH --account=g0610
#SBATCH --constraint=mil
#SBATCH --qos=debug

module load anaconda
conda activate diag

cd /discover/nobackup/amfox/GEOSldas_diagnostics/Jupyter/

python /discover/nobackup/amfox/GEOSldas_diagnostics/Jupyter/OMF_monthly_040125.py