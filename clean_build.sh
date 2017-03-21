echo 'Cleaning generated files (*.so, sample.cpp, tokenizers.cpp, utils.cpp)'
find . -name \*.so -delete
rm -f downsample/core/sample.cpp
rm -f downsample/core/tokenizers.cpp
rm -f downsample/core/utils.cpp

echo 
echo 'Touching files (sample.pyx, tokenizers.pyx, utils.pyx) so that they can compile'
echo '#' >> downsample/core/sample.pyx
echo '#' >> downsample/core/tokenizers.pyx
echo '#' >> downsample/core/utils.pyx


echo 
echo 'Building ..'
python setup.py build_ext --inplace
