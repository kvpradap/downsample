import pandas as pd
import numpy as np
from downsample.core.mur_wrapper_cy import get_str_cols, concat_cols, tokenize_n_rem_stopwords
from downsample.core.mur_wrapper_cy import build_inv_index, sample_pairs

from downsample.core.sample import sample_cython

from dask import delayed

def mur_sample(ltable, rtable, sample_size, y_param, stopword_list=[], num_chunks=1):

    ltbl_str_cols = get_str_cols(ltable)


    rtable = rtable.sample(sample_size, replace=False)
    rtbl_str_cols = get_str_cols(rtable)

    ltbl_concat_cols = concat_cols(ltable[ltbl_str_cols])
    rtbl_concat_cols = concat_cols(rtable[rtbl_str_cols])


    ret_tokens = tokenize_n_rem_stopwords(ltbl_concat_cols, rtbl_concat_cols, stopword_list)

    ltokens = ret_tokens[0]
    rtokens = ret_tokens[1]

    inv_index = build_inv_index(ltokens)

    list_indices = range(len(rtokens))


    rtoken_split = np.array_split(rtokens, num_chunks)
    indices_split = np.array_split(list_indices, num_chunks)

    l_ids = set()
    r_ids = set()
    for i in range(num_chunks):
        result = (sample_pairs)(rtoken_split[i], indices_split[i], inv_index, y_param)
        (l_ids.update)(result[0])
        (r_ids.update)(result[1])

    l_ids = sorted(l_ids)
    r_ids = sorted(r_ids)

    ltbl_sampled = ltable.iloc[l_ids]
    rtbl_sampled = rtable.iloc[r_ids]

    return (ltbl_sampled, rtbl_sampled)


def mur_sample_1(ltable, rtable, sample_size, y_param):
    ltbl_str_cols = get_str_cols(ltable)
    rtbl_str_cols = get_str_cols(rtable)

    ltbl_concat_cols = concat_cols(ltable[ltbl_str_cols])
    rtbl_concat_cols = concat_cols(rtable[rtbl_str_cols])

    ltable['dummy'] = ltbl_concat_cols
    rtable['dummy'] = rtbl_concat_cols

    ltbl_sampled, rtbl_sampled = sample_cython(ltable, rtable, 'id', 'id', 'dummy', 'dummy', sample_size, y_param, [], 1)
    return (ltbl_sampled, rtbl_sampled)




