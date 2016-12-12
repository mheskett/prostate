# -*- coding: utf-8 -*-
"""
Created on Fri Oct 14 07:36:29 2016

@author: mitcheas@ohsum01.ohsu.edu
"""

import string
import numpy as np



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

for n in names:
    q = n[0].split('.')[0]
    n = n[0] + '.depthofcov'
    fi = open(n, 'U')
    fi = read_file(fi)
    fi = np.asarray(fi)
    d = [float(i) for i in fi[:,1]]
    d = sorted(d)
    d = np.asarray(d)
    tot = float(len(d))
    med = np.median(d)
    mu = np.mean(d)
    x_10 = 100 * (1 - (((0 <= d) & (d <= 10)).sum()/tot))
    x_30 = 100 * (1 - (((0 <= d) & (d <= 30)).sum()/tot))
    x_50 = 100 * (1 - (((0 <= d) & (d <= 50)).sum()/tot))
    print (q, med, mu, x_10, x_30, x_50)
