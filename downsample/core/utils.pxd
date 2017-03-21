from libcpp.vector cimport vector
#from inverted_index cimport InvertedIndex
from downsample.core.inverted_index cimport InvertedIndex

cdef void build_inverted_index(vector[vector[int]]& token_vectors, InvertedIndex &index)

