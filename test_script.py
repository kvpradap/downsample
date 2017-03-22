import sys
sys.path.append('.')

import downsample
from downsample.core.sample import sample_cython

import py_stringsimjoin as ssj


A, B = ssj.load_person_dataset()
A.dropna(inplace=True)
B.dropna(inplace=True)
A['A.id'] = range(len(A))
B['B.id'] = range(len(B))


result = sample_cython(A, B, 'A.id', 'B.id', 'A.address', 'B.address', 4, 1)
print(result)
