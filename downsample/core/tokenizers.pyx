import time
from operator import itemgetter 

from cython.parallel import prange

from libc.stdlib cimport atoi
from libcpp.vector cimport vector
from libcpp.set cimport set as oset                                             
from libcpp.string cimport string
from libcpp cimport bool
from libcpp.map cimport map as omap                                             
from libcpp.pair cimport pair                                                   
from libc.stdio cimport printf, fprintf, fopen, fclose, FILE, sprintf


cdef extern from "string.h" nogil:                                                    
    #    char *strtok (char *inp_str, const char *delimiters)  
        char *strtok_r (char *inp_str, const char *delimiters, char **)


cdef extern from "<algorithm>" namespace "std" nogil:
        void sort(vector[int].iterator, vector[int].iterator)
    
cdef class WhitespaceTokenizer:
    cdef bool return_set

    def __init__(self, bool return_set):
        self.return_set = return_set

    cdef vector[string] tokenize(self, const string& inp_string) nogil:

        cdef char* ptr1
        cdef char* pch = strtok_r (<char*> inp_string.c_str(), " ", &ptr1)                          
        cdef oset[string] tokens                                                
        cdef vector[string] out_tokens                                          
        while pch != NULL:                                                  
            tokens.insert(string(pch))                                      
            pch = strtok_r (NULL, " ", &ptr1)                                        
        for s in tokens:                                                    
            out_tokens.push_back(s)                                         
        return out_tokens   

#        cdef char* pch                                                              
#        pch = strtok (<char*> inp_string.c_str(), " ") 
#        cdef oset[string] tokens                                            
#        cdef vector[string] out_tokens                                              
#        if self.return_set:                             
#            while pch != NULL:                                                          
#                tokens.insert(string(pch))                                          
#                pch = strtok (NULL, " ")
##            for s in tokens:
#                out_tokens.push_back(s)
#        else:
#            while pch != NULL:                                                  
#                out_tokens.push_back(string(pch))                                      
#                pch = strtok (NULL, " ")                                        
#
#        out_tokens.push_back(string("funny"))
#        return out_tokens     
    

cdef void tokenize_without_materializing(vector[string]& lstrings, 
                                          vector[string]& rstrings,         
                                          const string& tok_type,
                                          vector[vector[int]]& l_ordered_tokens,
                                          vector[vector[int]]& r_ordered_tokens,
                                          int n_jobs):
    
    cdef object tok
    cdef string s, token                                                        
    cdef vector[string] tokens                                                  
    cdef omap[string, int] token_freq, token_ordering                           
    cdef vector[vector[string]] ltokens, rtokens                                
                                                                               
    cdef int j, n1=lstrings.size(), n2=rstrings.size()

    cdef WhitespaceTokenizer ws_tok
    
    for j in range(n1):
        ltokens.push_back(vector[string]())

    for j in range(n2):
        rtokens.push_back(vector[string]())

    if tok_type.compare('ws') == 0:
        ws_tok = WhitespaceTokenizer(True)
        for j in prange(n1, nogil=True, num_threads=n_jobs):
            ltokens[j] = ws_tok.tokenize(lstrings[j])
        for j in prange(n2, nogil=True, num_threads=n_jobs):
            rtokens[j] = ws_tok.tokenize(rstrings[j])        
    for tokens in ltokens:
        for token in tokens:
            token_freq[token] += 1
    for tokens in rtokens:
        for token in tokens:
            token_freq[token] += 1
    ordered_tokens = []                                                         
    for entry in token_freq:                                                    
        ordered_tokens.append((entry.first, entry.second))                      
                                                                                
    cdef int order_idx = 1                                                      
    for token_freq_tuple in sorted(ordered_tokens, key=itemgetter(1)):          
        token_ordering[token_freq_tuple[0]] = order_idx                         
        order_idx += 1                                                          
   
    cdef vector[int] otokens                                                                             
    for tokens in ltokens:                                                                                                                  
        n = tokens.size()                                                       
        for j in range(n):                                                      
            otokens.push_back(token_ordering[tokens[j]])                           
        sort(otokens.begin(), otokens.end())
        l_ordered_tokens.push_back(otokens)
        otokens.clear()

    for tokens in rtokens:                                                                                           
        n = tokens.size()                                                       
        for j in range(n):                                                      
            otokens.push_back(token_ordering[tokens[j]])                           
        sort(otokens.begin(), otokens.end())
        r_ordered_tokens.push_back(otokens)
        otokens.clear()                          

def test_tok_ws(s):
    ws = WhitespaceTokenizer(True)
    str2bytes = lambda x: x if isinstance(x, bytes) else x.encode('utf-8')
    return ws.tokenize(str2bytes(s))

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
