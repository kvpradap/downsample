import sys
sys.path.append('.')

import downsample
from downsample.core.sample import sample_cython

import py_stringsimjoin as ssj
import pandas as pd

A = pd.read_csv('garage/movies.csv', usecols=['id', 'title'], low_memory=False)
B = pd.read_csv('garage/songs.csv', usecols=['id', 'title'], low_memory=False)

A.dropna(inplace=True)
B.dropna(inplace=True)
A.reset_index(inplace=True)
B.reset_index(inplace=True)
A['ID'] = range(len(A))
B['ID'] = range(len(B))

print(str(len(A)))
print(str(len(B)))
stopword_list = ['the', 'as', 'in']
import time
st = time.time()
table_a, table_b = sample_cython(A, B, 'id', 'id', 'title', 'title', 100000, 1, stopword_list, 4 )
print(time.time()-st)
print(str(len(table_a)))
print(str(len(table_b)))
