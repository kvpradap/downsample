import pandas as pd
import numpy as np

from libcpp.vector cimport vector
from libcpp.string cimport string
from downsample.core.tokenizers cimport tokenize_without_materializing








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




def mur_sample(ltable, rtable, sample_size, y_param, stopword_list):
    
    
    ltbl_str_cols = get_str_cols(ltable)

    rtable = rtable.sample(sample_size, replace=False)
    rtbl_str_cols = get_str_cols(rtable)

    ltbl_concat_cols = concat_cols(ltable[ltbl_str_cols])
    rtbl_concat_cols = concat_cols(rtable[rtbl_str_cols])

    ret_tokens = tokenize_n_rem_stopwords(ltbl_concat_cols, rtbl_concat_cols, stopword_list)

    return ret_tokens


    




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
