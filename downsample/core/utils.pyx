
from libcpp cimport bool
from libcpp.vector cimport vector                                               
from libcpp.string cimport string                                              
from libcpp.map cimport map as omap 

#from inverted_index cimport InvertedIndex
from downsample.core.inverted_index cimport InvertedIndex


cdef void build_inverted_index(vector[vector[int]]& token_vectors, InvertedIndex &inv_index):
    cdef vector[int] tokens, size_vector                                        
    cdef int i, j, m, n=token_vectors.size()                                    
    cdef omap[int, vector[int]] index                                           
    for i in range(n):                                                          
        tokens = token_vectors[i]                                               
        m = tokens.size()                                                       
        size_vector.push_back(m)                                                
        for j in range(m):                                                      
            index[tokens[j]].push_back(i)                                       
    inv_index.set_fields(index, size_vector)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
