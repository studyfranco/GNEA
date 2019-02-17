#!/bin/bash

#Suppression ancien outils
#rm 4alignement/STAR
rm 2convertion/samtools

#Creation of samtools
mkdir src
cd src
git clone https://github.com/samtools/htslib
git clone https://github.com/samtools/samtools
cd samtools
make
cp samtools ../../2convertion/
cd ../../

# Creation of STAR
# Doc : https://github.com/alexdobin/STAR
#git clone https://github.com/alexdobin/STAR.git
#cd STAR/source
# Build STAR
#make STAR
#cp STAR ../../4alignement/
#cd ../../

#rm -rf STAR
rm -rf src
