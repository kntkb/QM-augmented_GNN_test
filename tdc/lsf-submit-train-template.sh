#!/bin/bash
#BSUB -P "chemprop"
#BSUB -J "@@@JOBNAME@@@"
#BSUB -n 1
#BSUB -R rusage[mem=16]
#BSUB -R span[hosts=1]
#BSUB -q gpuqueue
#BSUB -sp 1 # low priority. default is 12, max is 25
#BSUB -gpu num=1:j_exclusive=yes:mode=shared
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
#conda activate chemprop-cpu
conda activate chemprop-gpu

# settings
group=@@@GROUP@@@
name=@@@NAME@@@
epochs=@@@EPOCHS@@@
output_dir=@@@OUTPUT_DIR@@@
index=@@@INDEX@@@
units=@@@UNITS@@@  # default 50
depth=@@@DEPTH@@@  # default 4
batchsize=@@@BATCHSIZE@@@  # default 10


# run
work_path=/home/takabak/data/qm-augmented-gnn-test/tdc/tdc
python ${work_path}/reactivity.py -m ml_QM_GNN --data_path ${work_path}/datasets/${group} --dataset_name ${name} --dataset_index ${index} --selec_epochs ${epochs} --output_dir ${work_path}/${output_dir} --model_dir ${work_path}/${output_dir} --feature ${units} --depth ${depth} --selec_batch_size ${batchsize}
