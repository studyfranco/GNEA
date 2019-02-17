#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH -o slurm.%N.%j.AlignMultiManual.out           # STDOUT
#SBATCH -e slurm.%N.%j.AlignMultiManual.err           # STDERR

folder=$4
readLength=$3
genome=$2
thred=$1

chemin=`pwd`

if [ ! -f $chemin/4alignement/genome/$genome/$readLength/SAindex ]
then
	4alignement/initialisationStar.sh $thred $genome $readLength
fi

listfastq=`ls $folder`

for file in $listfastq
do
	sbatch -N 1 -n $thred -t 7-00 --mem 40GB 4alignement/AlignManual.sh $thred $genome $readLength $folder/$file
done