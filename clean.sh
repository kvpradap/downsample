echo 'Cleaning generated files (*.so, sample.cpp, tokenizers.cpp, utils.cpp)'
find . -name \*.so -delete
rm -f downsample/core/sample.cpp
rm -f downsample/core/tokenizers.cpp
rm -f downsample/core/utils.cpp

