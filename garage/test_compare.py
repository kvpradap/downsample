import sys
sys.path.append('/Users/pradap/Documents/Research/Python-Package/pradap/downsample')
import os


from downsample.core.down_sample import down_sample
from downsample.core.sample import sample_cython

import py_entitymatching as em
import pandas as pd
import time
def _get_stop_words():
    stop_words_set = set()
    install_path = em.get_install_path()
    dataset_path = os.sep.join([install_path, 'utils'])
    stop_words_file = os.sep.join([dataset_path, 'stop_words.txt'])
    with open(stop_words_file, "rb") as stopwords_file:
        for stop_words in stopwords_file:
            stop_words_set.add(stop_words.rstrip())

    return stop_words_set

#A, B = ssj.load_books_dataset()
A = pd.read_csv('datasets/songs.csv', low_memory=False)
B = pd.read_csv('datasets/tracks.csv', low_memory=False)
print('Reading files done')

print(str(len(A)), str(len(B)))

print('Downsampling using em')
s = time.time()
_ = em.down_sample(A, B, 10000, 1)
print('Runtime (em: downsample): ' + str(time.time()-s))

print('Downsampling using cython (single core)')
stopwords = list(_get_stop_words())
s = time.time()
_ = down_sample(A, B, 10000, 1, stopwords_list=stopwords)
print('Runtime (dk: downsample:1): ' + str(time.time()-s))

print('Downsampling using cython (multi threaded)')
stopwords = list(_get_stop_words())
s = time.time()
_ = down_sample(A, B, 10000, 1, stopwords_list=stopwords, num_chunks=4)
print('Runtime (dk: downsample:4 (threads)): ' + str(time.time()-s))

print('Downsampling using cython (multi processing)')
stopwords = list(_get_stop_words())
s = time.time()
_ = down_sample(A, B, 10000, 1, stopwords_list=stopwords, num_chunks=4)
print('Runtime (dk: downsample:4(procs)): ' + str(time.time()-s))
