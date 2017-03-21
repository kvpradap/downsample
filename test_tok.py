import downsample
from downsample.core.tokenizers import test_tok_ws


s='down sample'
str2bytes = lambda x: x if isinstance(x, bytes) else x.encode('utf-8')
print(str2bytes(s))

res = test_tok_ws('down sample')
print(res)
