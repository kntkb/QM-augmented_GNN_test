#!/usr/bin/env python
# coding: utf-8


import os, sys, math
import glob
import click
import pandas as pd
from tdc.benchmark_group import admet_group

pd.options.display.precision = 3


def evaluate_many_custom_spearman(df, predictions_list, name):
    df_eval = pd.DataFrame()

    df_eval['y'] = df['activation_energy']
    for i, x in enumerate(predictions_list):
        df_eval[str(i)] = x[name]

    corr = df_eval.corr(method='spearman')
    print(corr)
    print(corr['y'][1:])
    _corr = {name: [corr['y'][1:].mean(), corr['y'][1:].std()]}

    return _corr



def eval(name, dirname):
    group = admet_group(path='datasets/data/')


    # load representative
    df = pd.read_csv('datasets/admet_group/{}_te.csv'.format(name), sep=',')


    # load predicted results
    files = glob.glob('results/{}/admet_group/{}/*/predicted.csv'.format(dirname, name))
    files.sort()

    if len(files) < 5:
        print("Warning: less than 5 experiments")
    elif len(files) > 5:
        print("More than 5 experiments found. First 5 experiments will be processed.")
        files = files[:5]
    try:
        files.remove("results/{}/admet_group/{}/results_{}.csv".format(dirname, name, name))
    except:
        pass


    predictions_list = []
    for file in files:
        print(file)
        #results = pd.read_csv(os.path.join(file, "predicted.csv"), sep=',', usecols=['predicted'])    
        results = pd.read_csv(file, sep=',', usecols=['predicted'])    
        
        predictions = {}
        predictions[name] = results.to_numpy().flatten()
        
        predictions_list.append(predictions)

    try:
        _results = group.evaluate_many(predictions_list)  # dict
    except:
        _results = evaluate_many_custom_spearman(df, predictions_list, name)
    print(_results)    

    # save
    results = {}
    results["avg"] = [_results[name][0]]
    results["std"] = [_results[name][1]]
    df = pd.DataFrame.from_dict(results).T
    df.to_csv('results/{}/admet_group/{}/results_{}.csv'.format(dirname, name, name), sep='\t', header=[name], float_format="%.3f")



@click.command()
@click.option("-n", "--name", required=True, type=click.Choice(["caco2_wang", "vdss_lombardo", "half_life_obach", "clearance_hepatocyte_az", "clearance_microsome_az"]),
              help="Dataset name from admet_group in TDC")
@click.option("-d", "--dirname", required=True, type=str, help="Working directory name")
def cli(**kwargs):
    name = kwargs['name']
    dirname = kwargs['dirname']
    eval(name, dirname)



if __name__ == "__main__":
    cli()



