import downsample
from downsample.core.tokenizers import test_tok_ws
from downsample.core.tokenizers import test_stop_words


s='down sample'
str2bytes = lambda x: x if isinstance(x, bytes) else x.encode('utf-8')
print(str2bytes(s))
inp_string = 'this is the first test on                 down sample'
res = test_stop_words('this the', [b'this', b'the'])
print(res)

#res = test_tok_ws('this is the first test on                 down sample')
#print(res)
