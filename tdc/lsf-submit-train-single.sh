#!/bin/bash
#BSUB -P "chemprop"
#BSUB -J "qm-gnn"
#BSUB -n 1
#BSUB -R rusage[mem=16]
#BSUB -R span[hosts=1]
#BSUB -q cpuqueue
#BSUB -sp 1 # low priority. default is 12, max is 25
#BSUB -W 23:59
#BSUB -o out_%J_%I.stdout
#BSUB -eo out_%J_%I.stderr
#BSUB -L /bin/bash

source ~/.bashrc
OPENMM_CPU_THREADS=1
#export OE_LICENSE=~/.openeye/oe_license.txt   # Open eye license activation/env


# chnage dir
echo "changing directory to ${LS_SUBCWD}"
cd $LS_SUBCWD


# Report node in use
echo "======================"
hostname
env | sort | grep 'CUDA'
nvidia-smi
echo "======================"


# conda
conda activate chemprop-cpu

# settings
group="admet_group"
name="caco2_wang"
epochs=200
output_dir="results/${group}/${name}"

# directory
mkdir -p results
mkdir -p results/${group}
mkdir -p results/${group}/${name}

# run single
i=1
echo "process index #${i}"
mkdir results/${group}/${name}/${i}
python reactivity.py -m ml_QM_GNN --data_path datasets/${group} --dataset_name ${name} --dataset_index ${i} --selec_epochs ${epochs} --output_dir ${output_dir}/${i} --model_dir ${output_dir}/${i}
