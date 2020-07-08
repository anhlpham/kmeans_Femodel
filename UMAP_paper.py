# -*- coding: utf-8 -*-
"""
Created on %(date)s

@author: %(username)s
"""

import numpy as np
from sklearn.datasets import load_iris, load_digits
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from scipy.io import loadmat
from numpy import linspace
from numpy import meshgrid
from matplotlib.backends.backend_pdf import PdfPages
%matplotlib inline

sns.set(style='white', context='notebook', rc={'figure.figsize':(14,10)})

annots = loadmat('Parekh_dust2.mat')
annots.keys()
Xn = annots['Xn'];

type(annots['Xn']),annots['Xn'].shape

IDX_new = annots['IDX_new']
IDX = np.reshape(IDX_new,(35456))

target = np.array([1, 2, 3, 4]);
print(Xn)
print(type(Xn))
X_df = pd.DataFrame(Xn)
X_df['class'] = pd.Series(IDX)
#.map(dict(zip(range(3),target)))
with PdfPages('Visulization.pdf') as pdf:
    sns.pairplot(X_df, hue='class');
    pdf.savefig() 
    
import umap
reducer = umap.UMAP()
embedding = reducer.fit_transform(Xn)
embedding.shape

plt.scatter(embedding[:, 0], embedding[:, 1], c=[sns.color_palette()[x] for x in IDX])
plt.gca().set_aspect('equal', 'datalim')
plt.title('UMAP projection of sFe-dust model', fontsize=24);
plt.savefig('UMAP-sFe-dust.pdf')