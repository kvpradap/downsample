from libcpp.vector cimport vector                                               
from libcpp.string cimport string  

cdef void tokenize_without_materializing(const vector[string]&,             
                                          const vector[string]&,             
                                          const vector[string]&,               
                                          vector[vector[int]]&, 
                                          vector[vector[int]]&, int n_jobs)
