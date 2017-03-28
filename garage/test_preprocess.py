import pandas as pd
import py_stringsimjoin as ssj
import numpy as np

A, B = ssj.load_books_dataset()

def concat_cols(*column_values):
    strs = [str(column_value) for column_value in column_values if not pd.isnull(column_value)]
    ret_val = ' '.join(strs) if strs else ''
    return ret_val.strip().lower()

np_concat_cols = np.vectorize(concat_cols)

def get_str_cols(dataframe):
    if len(dataframe) == 0:
        raise AssertionError('Size of input table is 0')

    cols = list(dataframe.columns[dataframe.dtypes == object])
    return cols

str_cols_df_A = get_str_cols(A)
str_cols_df_B = get_str_cols(B)



B1 = B[str_cols_df_B]
import time
s = time.time()
concat_cols_df_A = np_concat_cols(*(A[str_cols_df_A]).T.values)
print(time.time() - s)
# concat_cols_df_B = np_concat_cols(*B[str_cols_df_B].T.values)
print()
s = time.time()
A1 = A[str_cols_df_A]
concat_cols_df_A = np_concat_cols(*A1.T.values)
print(time.time() - s)


print(type(concat_cols_df_A))
# print(type(concat_cols_df_B))








