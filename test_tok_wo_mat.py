import downsample
from downsample.core.tokenizers import tokenize_without_materializing
from downsample.core.sample import convert_to_string_vector

import py_stringsimjoin as ssj

A, B = ssj.load_books_dataset()
A.dropna(inplace=True)
B.dropna(inplace=True)

cdef vector[string] lstrings, rstrings

convert_to_string_vector(ltable['A.address'], lstrings)
convert_to_string_vector(ltable['B.address'], rstrings)


cdef vector[vector[int]] ltokens, rtokens

tokenize_without_materializing(lstrings, rstrings, 'ws', ltokens, rtokens, 1)
