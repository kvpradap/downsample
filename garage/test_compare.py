import sys
sys.path.append('/Users/pradap/Documents/Research/Python-Package/pradap/downsample')


from downsample.core.mur_sample import mur_sample, mur_sample_1
from downsample.core.sample import sample_cython
import py_entitymatching as em
import py_stringsimjoin as ssj
import time
A, B = ssj.load_books_dataset()

s = time.time()
sample_a, sample_b = em.down_sample(A, B, 2300, 1)
print('Runtime (em: downsample): ' + str(time.time()-s))

s = time.time()
sample_a, sample_b = mur_sample(A, B, 2300, 1)
print('Runtime (cy: downsample): ' + str(time.time()-s))

s = time.time()
sample_a, sample_b = mur_sample_1(A, B, 2300, 1)
print('Runtime (cy (older): downsample): ' + str(time.time()-s))
