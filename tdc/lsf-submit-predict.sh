#!/bin/bash
#BSUB -P "chemprop"
#BSUB -J "qm-gnn"
#BSUB -n 1
#BSUB -R rusage[mem=16]
#BSUB -R span[hosts=1]
####BSUB -q cpuqueue
#BSUB -q gpuqueue
#BSUB -sp 1 # low priority. default is 12, max is 25
#BSUB -gpu num=1:j_exclusive=yes:mode=shared
#BSUB -W 1:59
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


# run
#conda activate chemprop-cpu
conda activate chemprop-gpu


# settings
group=admet_group
#names=('caco2_wang' 'vdss_lombardo' 'half_life_obach' 'clearance_hepatocyte_az' 'clearance_microsome_az')
names=('caco2_wang')
work_path=/home/takabak/data/qm-augmented-gnn-test/tdc/tdc
basename=epochs-200-units-128-depth-4-batchsize-32

# same as training
units=128     # default: 50
depth=4       # default: 4


# run
for name in ${names[*]};
do
    echo "process ${name}"        
    #for index in {1..5};
    for index in {3..3};
    do
        output_dir=results/${basename}/admet_group/${name}/${index}
        if [ -d ${output_dir} ]
        then
            python ${work_path}/reactivity.py -m ml_QM_GNN --data_path ${work_path}/datasets/${group} --dataset_name ${name} --dataset_index ${index} --output_dir ${work_path}/${output_dir} --model_dir ${work_path}/${output_dir} --feature ${units} --depth ${depth} -p
        fi
    done
done
