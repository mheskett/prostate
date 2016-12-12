# -*- coding: utf-8 -*-
"""
Created on Fri Oct 14 03:07:45 2016

@author: mitcheas@ohsum01.ohsu.edu
"""
import string
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm


# FUNCTION: READ_FILE(FILENAME)
# Reads all lines of an input file except for the first line.
# Use to read lines of a file containing a header
def read_file(Filename):
    alllines = Filename.readlines()
    numlines = len(alllines)
    Filename = alllines[1:numlines]
    filename = []
    for line in Filename:
        line = string.rstrip(line)
        line = string.split(line, '\t')
        filename.append(line)
    return filename
    
names = open('filenames.txt', 'U')
names = read_file(names)

fig = plt.figure(figsize=(11, 8.5), dpi=300, facecolor='w', edgecolor='none')
for indx, n in enumerate(names):
    print n[0]
    q = n[0].split('.')[0]
    n = n[0] + '.depthofcov'
    fi = open(n, 'U')
    fi = read_file(fi)
    fi = np.asarray(fi)
    print fi.shape
    d = [float(i) for i in fi[:,1]]
    d = sorted(d)
    d = np.asarray(d)
    #m = max(d)
    m = 305
    tot = float(len(d))
    X = np.arange(5, m, 5)
    X = np.append(X, [0, 1])
    X = np.sort(X)
    Y = []
    for i in X:
	if i < 300:
        	c = ((0 <= d) & (d <= i)).sum()
        	c = (c/tot) * 100
        else:
        	c = ((0 <= d) & (d <= max(d))).sum()
        	c = (c/tot) * 100
        Y.append(c)
    plt.plot(X, Y, color=cm.ocean(indx*5), label=q)
plt.xlabel('Depth')
plt.ylabel('Percent of Bases Covered')
plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
           ncol=3, mode="expand", borderaxespad=1.5,prop={'size':8})
plt.savefig('coverage.pdf', format='pdf')

