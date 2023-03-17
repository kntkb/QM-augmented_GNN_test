#!/bin/bash

#
# Settings
#
epochs=200
#units=128     # default: 50
#batchsize=32  # default: 10
units=50
batchsize=10
depth=4       # default: 4
basename=epochs-${epochs}-units-${units}-depth-${depth}-batchsize-${batchsize}

#
# Group and dataset name
#
group="admet_group"
names=('caco2_wang' 'vdss_lombardo' 'half_life_obach' 'clearance_hepatocyte_az' 'clearance_microsome_az')
#names=('caco2_wang')


#
# Run
#
DIR=${PWD}
for name in ${names[*]};
do
    cd ${DIR}
    echo "process ${name}"
    for i in {1..5};
    do
        output_dir="./results/${basename}/${group}/${name}/${i}"
        mkdir -p ${output_dir}

        sed -e 's/@@@JOBNAME@@@/'${name}'-'${i}'/g' \
            -e 's/@@@GROUP@@@/'${group}'/g' \
            -e 's/@@@NAME@@@/'${name}'/g' \
            -e 's/@@@EPOCHS@@@/'${epochs}'/g' \
            -e 's/@@@OUTPUT_DIR@@@/results\/'${basename}'\/'${group}'\/'${name}'\/'${i}'/g' \
            -e 's/@@@INDEX@@@/'${i}'/g' \
            -e 's/@@@UNITS@@@/'${units}'/g' \
            -e 's/@@@DEPTH@@@/'${depth}'/g' \
            -e 's/@@@BATCHSIZE@@@/'${batchsize}'/g' \
            lsf-submit-train-template.sh > ./${output_dir}/submit-train.sh
            
        cd ${output_dir}
        echo "submit job ${name}-${i}"
        bsub < submit-train.sh
        cd ${DIR}
    done
done