#!/usr/bin/env bash
echo 'Cleaning generated files (*.so, sample.cpp, tokenizers.cpp, utils.cpp)'
find . -name \*.so -delete
rm -f downsample/core/sample.cpp
rm -f downsample/core/mur_wrapper_cy.cpp
rm -f downsample/core/tokenizers.cpp
rm -f downsample/core/utils.cpp

echo 
echo 'Touching files (mur_wrapper_cy.pyx, sample.pyx, tokenizers.pyx, utils.pyx) so that they can compile'
echo '#' >> downsample/core/mur_wrapper_cy.pyx
echo '#' >> downsample/core/tokenizers.pyx
echo '#' >> downsample/core/utils.pyx


echo 
echo 'Building ..'
rm -f err
python setup.py build_ext --inplace 2> err

echo; echo
echo "Num. errors:`cat err|grep -i error|wc -l`"

