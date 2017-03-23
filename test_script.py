import sys
sys.path.append('.')

import downsample
from downsample.core.sample import sample_cython

import py_stringsimjoin as ssj


A, B = ssj.load_books_dataset()
A.dropna(inplace=True)
B.dropna(inplace=True)
A['ID'] = range(len(A))
B['ID'] = range(len(B))

stopword_list = ['108', 'St']
import time
st = time.time()
table_a, table_b = sample_cython(A, B, 'ID', 'ID', 'Title', 'Title', 3000, 1, stopword_list, 1 )
print(time.time()-st)
print(str(len(table_a)))
print(str(len(table_b)))
