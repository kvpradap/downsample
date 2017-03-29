import pandas as pd
import numpy as np
from downsample.core.mur_wrapper_cy import get_str_cols, concat_cols, tokenize_n_rem_stopwords
from downsample.core.mur_wrapper_cy import build_inv_index, sample_pairs

from dask import delayed

def down_sample(ltable, rtable, sample_size, y_param, stopword_list=[], num_chunks=1):

    # preprocess input tables
    ltbl = (delayed)(pre_process_ltable)(ltable)
    rtbl = (delayed)(pre_process_rtable)(rtable, sample_size)


    # tokenize
    ret_tokens = (delayed)(tokenize_n_rem_stopwords)(ltbl, rtbl, stopword_list)

    ltokens = ret_tokens[0]
    rtokens = ret_tokens[1]


    # build inverted index
    inv_index = (delayed)(build_inv_index)(ltokens)


    # probe
    rtoken_split = (delayed)(get_token_splits)(rtokens, num_chunks)
    indices_split = (delayed)(get_index_splits)(rtokens, num_chunks)

    result_list = []
    for i in range(num_chunks):
        result = (delayed)(sample_pairs)(rtoken_split[i], indices_split[i], inv_index, y_param)
        result_list.append(result)

    # postprocess
    result = (delayed)(post_process)(result_list, ltable, rtable)
    return result



def pre_process_ltable(ltable):
    ltbl_str_cols = (get_str_cols)(ltable)
    return (concat_cols)(ltable[ltbl_str_cols])

def pre_process_rtable(rtable, sample_size):
    rtable = (rtable.sample)(sample_size, replace=False)
    rtbl_str_cols = (get_str_cols)(rtable)
    return (concat_cols)(rtable[rtbl_str_cols])


def post_process(result_list, ltable, rtable):
    l_ids = set()
    r_ids = set()
    for i in range(len(result_list)):
        result = result_list[i]
        l_ids.update(result[0])
        r_ids.update(result[1])
    l_ids = sorted(l_ids)
    r_ids = sorted(r_ids)
    ltable_sampled = ltable.iloc[l_ids]
    rtable_sampled = rtable.iloc[r_ids]
    return (ltable_sampled, rtable_sampled)

def get_token_splits(tokens, num_chunks):
    return np.array_split(tokens, num_chunks)
def get_index_splits(tokens, num_chunks):
    list_indices = range(len(tokens))
    return np.array_split(list_indices, num_chunks)
