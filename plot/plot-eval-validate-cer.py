#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.interpolate import UnivariateSpline

arg_parser = argparse.ArgumentParser(
    '''Creates plot from Training and Evaluation Character Error Rates''')

arg_parser.add_argument('-m', '--model', nargs='?',
                        metavar='MODEL_NAME', help='Model Name', required=True)

arg_parser.add_argument('-v', '--validatelist', nargs='?', metavar='VALIDATELIST',
                        help='Validate List Suffix', required=True)

args = arg_parser.parse_args()

ytsvfile = "tmp-" + args.model + "-" + args.validatelist + "-iteration.tsv"
ctsvfile = "tmp-" + args.model + "-" + args.validatelist + "-checkpoint.tsv"
etsvfile = "tmp-" + args.model + "-" + args.validatelist + "-eval.tsv"
vtsvfile = "tmp-" + args.model + "-" + args.validatelist + "-validate.tsv"
plotfile = "../data/" + args.model + "/plot/" + args.model + "-" + args.validatelist + "-cer.png"

ydf = pd.read_csv(ytsvfile,sep='\t', encoding='utf-8')
cdf = pd.read_csv(ctsvfile,sep='\t', encoding='utf-8')
edf = pd.read_csv(etsvfile,sep='\t', encoding='utf-8')
vdf = pd.read_csv(vtsvfile,sep='\t', encoding='utf-8')

t = ydf['TrainingIteration']
x = ydf['LearningIteration']
y = ydf['IterationCER']

c = cdf['CheckpointCER']
cx = cdf['LearningIteration']
e = edf['EvalCER']
ex = edf['LearningIteration']
v = vdf['ValidationCER']
vx = vdf['LearningIteration']

trainlistfile = "../data/" + args.model + "/list.train"
evalistfile = "../data/" + args.model + "/list.eval"
validatelistfile = "../data/" + args.model + "/list." + args.validatelist

trainlistlinecount = len(open(trainlistfile).readlines(  ))
evallistlinecount = len(open(evalistfile).readlines(  ))
validatelistlinecount = len(open(validatelistfile).readlines(  ))

maxticks=10

def annot_min(boxcolor, xpos, ypos, x,y):
    xmin = x[np.argmin(y)]
    ymin = y.min()
    boxtext= "{:.3f}% at {:.0f}" .format(ymin,xmin)
    ax1.annotate(boxtext, xy=(xmin, ymin), xytext=(xpos,ypos), textcoords='offset points',
            arrowprops=dict(shrinkA=1, shrinkB=1, fc='black', ec='white', connectionstyle="arc3"),
            bbox=dict(boxstyle='round,pad=0.2', fc=boxcolor, alpha=0.3))

PlotTitle="Tesseract LSTM Training - Model Name = " + args.model + ", Validation List = list." + args.validatelist
fig = plt.figure(figsize=(11,8.5)) #size is in inches
ax1 = fig.add_subplot()

ax1.yaxis.set_major_formatter(matplotlib.ticker.ScalarFormatter())
ax1.yaxis.set_major_formatter(matplotlib.ticker.FormatStrFormatter("%.1f"))
ax1.set_ylabel('Character Error Rate %')

ax1.set_xlabel('Learning Iterations')
ax1.set_xticks(x)
ax1.tick_params(axis='x', rotation=45, labelsize='small')
ax1.locator_params(axis='x', nbins=maxticks)  # limit ticks on x-axis
ax1.grid(True)

ax1.plot(x, y, 'teal', alpha=0.7, label='CER every 100 Training Iterations', linewidth=0.5)

if not c.dropna().empty: # not NaN or empty
	ax1.scatter(cx, c, c='teal', s=10,
    label='Checkpoints CER  from lstmtraining (list.train - ' +
    str(trainlistlinecount) +' lines)', alpha=0.7)
	annot_min('teal',-0,-30,cx,c)

if not e.dropna().empty: # not NaN or empty
#	ax1.plot(ex, e, 'magenta', linestyle="dotted")
	ax1.scatter(ex, e, c='magenta', s=10,
    label='Evaluation CER from lstmtraining (list.eval - ' +
    str(evallistlinecount) +' lines)', alpha=0.7)
	annot_min('magenta',-0,30,ex,e)

if not v.dropna().empty: # not NaN or empty
#	ax1.plot(vx, v, 'maroon', linestyle='dotted')
	ax1.scatter(vx, v, c='maroon', s=10,
    label='Validation CER from lstmeval (list.'  + args.validatelist +
    ' - ' + str(validatelistlinecount) +' lines)', alpha=0.7)
	annot_min('maroon',-0,60,vx,v)

ax1.set_xlim([0,None])
ax1.set_ylim([-0.5,None])

# Best fit curve for training data using spline
spliney = UnivariateSpline(x, y)
yxs = np.linspace(x.min(), x.max(), 1000)
ysy = spliney(yxs)
ax1.plot(yxs, ysy, 'teal')
# Best fit curve for eval data using spline
if not e.dropna().empty: # not NaN or empty
	splinee = UnivariateSpline(ex, e)
	exs = np.linspace(ex.min(), ex.max(), 50)
	ese = splinee(exs)
	ax1.plot(exs, ese, 'magenta')
# Best fit curve for validation data using spline
if not v.dropna().empty: # not NaN or empty
	splinev = UnivariateSpline(vx, v)
	vxs = np.linspace(vx.min(), vx.max(), 50)
	vsv = splinev(vxs)
	ax1.plot(vxs, vsv, 'maroon')

plt.title(label=PlotTitle)
plt.legend(loc='upper right')

# Secondary x axis on top to display Training Iterations
ax2 = ax1.twiny() # ax1 and ax2 share y-axis
ax2.set_xlabel("Training Iterations")
ax2.set_xlim(ax1.get_xlim()) # ensure the independant x-axes now span the same range
ax2.set_xticks(x) # copy over the locations of the x-ticks from Learning Iterations
ax2.tick_params(axis='x', rotation=45, labelsize='small')
ax2.set_xticklabels(t) # But give value of Training Iterations
ax2.locator_params(axis='x', nbins=maxticks)  # limit ticks to same as x-axis

plt.savefig(plotfile)
