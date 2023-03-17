#!/usr/bin/env python
# coding: utf-8
import os, sys
import click
import pandas as pd
from tdc.utils import retrieve_all_benchmarks, retrieve_benchmark_names, retrieve_dataset_names
from tdc import BenchmarkGroup
from openff.toolkit import Molecule



def _dataframe_to_csv(df, output_prefix):
    # dataframe
    new_df = pd.DataFrame(columns=["", "reaction_id", "smiles", "reaction_core", "activation_energy"])
    
    for idx, _df in enumerate(df.iterrows()):
        _smi = _df[1]['Drug']
        try:
            m = Molecule.from_smiles(_smi, allow_undefined_stereo=True)

            # create dummy reaction core
            for n in range(1, m.n_atoms+1):
                if n == 1:
                    l = "[["
                l += str(n)
                if n != m.n_atoms:
                    l += ','
                if n == m.n_atoms:
                    l += "]]"

            # create mapped smiles
            smi = m.to_smiles(mapped=True)

            # observable
            y = _df[1]['Y']

            # append to dataframe
            if "I:" in smi or "B:" in smi or "P:" in smi or "Li+:" in smi or "I-:" in smi or "Si:" in smi:
                print("unsupported atom")
            else:
                new_df = new_df.append(
                    { 
                      "": idx,
                      "reaction_id": idx,
                      "smiles": smi,
                      "reaction_core": l,
                      "activation_energy": y
                    },
                    ignore_index=True,
                )
        except:
            pass
            
    new_df.to_csv('{}.csv'.format(output_prefix), sep=',')



#def export_csv(group_name, data):
def export_csv(group, group_name, dataset_name):
    # -----------
    # https://tdcommons.ai/benchmark/overview/
    # https://tdc.readthedocs.io/en/main/_modules/tdc/benchmark_group/base_group.html#BenchmarkGroup.get_train_valid_split
    # -----------
    
    data = group.get(dataset_name)
    name = data['name']

    for random_seed in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]:
        df_tr_vl, df_te = data['train_val'], data['test']   # pandas dataframe
        df_tr, df_vl = group.get_train_valid_split(benchmark=name, split_type='default', seed=random_seed)
        
        # train
        output_prefix = os.path.join(group_name, name + "_tr" + "_" + str(random_seed))
        _dataframe_to_csv(df_tr, output_prefix)

        # validate
        output_prefix = os.path.join(group_name, name + "_vl" + "_" + str(random_seed))
        _dataframe_to_csv(df_vl, output_prefix)

        # test
        if random_seed == 1:
            #output_prefix = os.path.join(group_name, name + "_te" + "_" + str(random_seed))
            output_prefix = os.path.join(group_name, name + "_te")
            _dataframe_to_csv(df_te, output_prefix)



@click.command()
@click.option("-n", "--name", required=True, type=click.Choice(["admet_group", "drugcombdo_group", "docking_group", "dti_dg_group"]),
              help="Benchmark group name supported by TDC. Run tdc.utils.retrieve_all_benchmarks.")
def cli(**kwargs):
    group_name = kwargs['name']
    group = BenchmarkGroup(name = group_name)

    # make output directory
    if not os.path.exists(group_name):
        os.mkdir(group_name)

    SELECTED_DATASETS = ['caco2_wang', 'vdss_lombardo', 'half_life_obach', 'clearance_hepatocyte_az', 'clearance_microsome_az']
    for dataset_name in retrieve_benchmark_names('admet_group'):
        if dataset_name in SELECTED_DATASETS:
            print(dataset_name)
            #data = group.get(benchmark_name)
            #export_csv(group_name, data)    
            export_csv(group, group_name, dataset_name)



if __name__ == "__main__":
    cli()