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

cdef vector[string] remove_stopwords(vector[string] &inp_tokens, const omap[string, int] &stop_words) nogil:
    cdef vector[string] out_tokens
    cdef string token
    for token in inp_tokens:
        if (stop_words.find(token) == stop_words.end()):
            out_tokens.push_back(token)
    return out_tokens
    

    
cdef class WhitespaceTokenizer:
    cdef bool return_set

    def __init__(self, bool return_set):
        self.return_set = return_set

    cdef vector[string] tokenize(self, const string& inp_string) nogil:

        cdef char* ptr1
        cdef char* pch = strtok_r (<char*> inp_string.c_str(), " \t\n", &ptr1)                          
        cdef oset[string] tokens                                                
        cdef vector[string] out_tokens                                          
        while pch != NULL:                                                  
            tokens.insert(string(pch))                                      
            pch = strtok_r (NULL, " \t\n", &ptr1)                                        
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
                                          vector[string]& stopwords,
                                          vector[vector[int]]& l_ordered_tokens,
                                          vector[vector[int]]& r_ordered_tokens,
                                          int n_jobs):
    
    cdef object tok
    cdef string s, token                                                        
    cdef vector[string] tokens                                                  
    cdef omap[string, int] token_freq, token_ordering, stopword_map                           
    cdef vector[vector[string]] ltokens, rtokens                                
                                                                               
    cdef int j, n1=lstrings.size(), n2=rstrings.size()
    cdef int ns = stopwords.size()

    cdef WhitespaceTokenizer ws_tok
    
    for j in range(n1):
        ltokens.push_back(vector[string]())

    for j in range(n2):
        rtokens.push_back(vector[string]())

    for j in range(ns):
        stopword_map[stopwords[j]] = 0

    ws_tok = WhitespaceTokenizer(True)
    for j in prange(n1, nogil=True, num_threads=n_jobs):
        tokens = ws_tok.tokenize(lstrings[j])
        ltokens[j] = remove_stopwords(tokens, stopword_map)
    for j in prange(n2, nogil=True, num_threads=n_jobs):
        tokens = ws_tok.tokenize(rstrings[j])        
        rtokens[j] = remove_stopwords(tokens, stopword_map)

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

def test_stop_words(inp_string, stopwords_list ):
    cdef omap[string, int] stopword_map
    str2bytes = lambda x: x if isinstance(x, bytes) else x.encode('utf-8')
    for word in stopwords_list:
        stopword_map[word] = 0
    ws = WhitespaceTokenizer(True)
    token_list = ws.tokenize(str2bytes(inp_string))
    updated_tok_list = remove_stopwords(token_list, stopword_map)
    return updated_tok_list
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
