from downsample.core.mur_sample import mur_sample
import py_stringsimjoin as ssj

A, B = ssj.load_person_dataset()
A.dropna(inplace=True)
B.dropna(inplace=True)

A.reset_index(inplace=True, drop=True)
B.reset_index(inplace=True, drop=True)

res = mur_sample(A, B, 4, 1, [])

print(res)
