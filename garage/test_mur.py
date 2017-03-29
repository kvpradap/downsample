import sys
sys.path.append('/Users/pradap/Documents/Research/Python-Package/pradap/downsample')
from downsample.core.mur_sample import mur_sample
import py_stringsimjoin as ssj


A, B = ssj.load_books_dataset()
A.dropna(inplace=True)
B.dropna(inplace=True)

A.reset_index(inplace=True, drop=True)
B.reset_index(inplace=True, drop=True)


import time
s = time.time()
res = mur_sample(A, B,2300, 1, num_chunks=10)
print(time.time() - s)
#print(res[0])
#print(res[1])
