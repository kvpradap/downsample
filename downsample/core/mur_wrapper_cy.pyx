
import pandas as pd
import numpy as np

from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.set cimport set as oset
from libcpp.map cimport map as omap
from libcpp cimport bool
from libcpp.pair cimport pair                                                   
from libcpp.algorithm cimport sort



from downsample.core.tokenizers cimport tokenize_without_materializing
from downsample.core.inverted_index cimport InvertedIndex
from downsample.core.utils cimport build_inverted_index

import time


def _concat_cols(*column_values):
    strs = [str(column_value) for column_value in column_values if not pd.isnull(column_value)]
    ret_val = ' '.join(strs) if strs else ''
    return ret_val.strip().lower()


def concat_cols(dataframe):
    np_concat_cols = np.vectorize(_concat_cols)
    return np_concat_cols(*dataframe.T.values)


def get_str_cols(dataframe):
    if len(dataframe) == 0:
        raise AssertionError('Size of input table is 0')

    cols = list(dataframe.columns[dataframe.dtypes == object])
    return cols



def tokenize_n_rem_stopwords(lvalues, rvalues, stopword_list, n_jobs=1):
    cdef vector[string] lstrings, rstrings, stopwords
    cdef vector[vector[int]] ltokens, rtokens

    convert_to_string_vector(lvalues, lstrings)
    convert_to_string_vector(rvalues, rstrings)
    convert_to_string_vector(stopword_list, stopwords)

    tokenize_without_materializing(lstrings, rstrings, stopwords, ltokens, rtokens, n_jobs)

    ret_ltokens = []
    ret_rtokens = []

    ret_ltokens = ltokens
    ret_rtokens = rtokens

    return (ret_ltokens, ret_rtokens)


def build_inv_index(token_list):
    cdef InvertedIndex index
    cdef vector[vector[int]] toks

    toks = token_list
    build_inverted_index(toks, index)
    ret_index = {}
    ret_index = index.index
    
    return ret_index



cdef _sample_pairs(vector[vector[int]] &rtokens, vector[int]&indices, InvertedIndex &inv_index, int y_param, 
        vector[pair[int, int]]&sample):
    cdef oset[int] sample_ltable_indices
    cdef omap[int, int] candidate_overlap
    cdef vector[pair[int, int]] tmp
    cdef vector[int] candidates, tokens
    cdef pair[int, int] entry
    cdef int i, j, m=0, k=0, n=indices.size()
    for i in range(len(indices)):
        tokens = rtokens[i]
        m+=1
        for j in range(tokens.size()):
            candidates = inv_index.index[tokens[j]]
            for cand in candidates:
                candidate_overlap[cand] += 1
        for entry in candidate_overlap:
            tmp.push_back(entry)
        sort(tmp.begin(), tmp.end(), comp)

        k = 0
        for entry in tmp:
            sample_ltable_indices.insert(entry.first)
            k += 1
            if k == y_param:
                break
        for k in sample_ltable_indices:
            sample.push_back(pair[int, int](k, i))
        candidate_overlap.clear()
        sample_ltable_indices.clear()
        tmp.clear()
        


def sample_pairs(token_list, list_indices, inv_index, y_param):
    cdef InvertedIndex index
    cdef vector[vector[int]] rtokens = token_list
    cdef vector[int] indices = list_indices
    cdef vector[pair[int, int]] sample
    cdef int yparam = <int> y_param

    index.index = inv_index
    
    _sample_pairs(rtokens, indices, index, yparam, sample)
    sample_l_ids = []
    sample_r_ids = []

    cdef pair[int, int] entry
    for entry in sample:
        sample_l_ids.append(entry.first)
        sample_r_ids.append(indices[entry.second])

    return (sample_l_ids, sample_r_ids)





#    cdef oset[int] sample_ltable_indices
#    cdef omap[int, int] candidate_overlap
#    #cdef vector[int] candidates, tokens
#    cdef vector[pair[int, int]] tmp
#    #cdef vector[pair[int, int]] sample
#    cdef pair[int, int] entry
#    cdef int ltuples_required = <int> y_param
#    cdef InvertedIndex index
#    cdef int cand
#    sample = []

#    print('Before copying inv. index')
#    index.index = inv_index

#    cdef int i, j, m=0, k=0, n=len(list_indices)
#
#    print('Probing starts !!')
#    for i in range(n):
#        tokens = token_list[i]
#        m += 1
#        for j in range(len(tokens)):
#            candidates = index.index[tokens[j]]
#            for cand in candidates:
#                candidate_overlap[cand] += 1
#        for entry in candidate_overlap:
#            tmp.push_back(entry)
#
#        # sort
#        sort(tmp.begin(), tmp.end(), comp)
#    
#        # get ltable indices
#        k = 0
#        for entry in tmp:
#            sample_ltable_indices.insert(entry.first)
#            k += 1
#            if k == ltuples_required:
#                break
#
#        # fill the sample pairs to be returned
#        for k in sample_ltable_indices:
#            sample.append((k, i))
#    
#        # clean up
#        candidate_overlap.clear()
#        sample_ltable_indices.clear()
#        tmp.clear()
#    print('Probing ends !!')

    return sample



cdef bool comp(const pair[int, int]& l, const pair[int, int]& r):
    return l.second > r.second   









# utils
cdef void convert_to_string_vector(string_col, vector[string]& string_vector, lowercase=False):
    str2bytes = lambda x: x if isinstance(x, bytes) else x.encode('utf-8')
    if lowercase:
        for val in string_col:
            string_vector.push_back(str2bytes(val.lower()))
    else:
        for val in string_col:
            string_vector.push_back(str2bytes(val))

cdef void convert_to_int_vector(int_col, vector[int]& int_vector):
    for val in int_col:
        int_vector.push_back(int(val))
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
