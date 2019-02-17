#!/bin/bash


sens=$2
ftype="fastq"
thread=$1
Gref=$3
lread=$4
nming=$5
nmint=$6



#Faire une fonction d'initialisation de star si le dossier pour le génome n'existe pas

if [ "${0:0:2}" = "./" ]
then
	let "longeur=${#0}-9"
	chemin=`pwd`/${0:1:$longeur}
else
	let "longeur=${#0}-8"
	chemin=${0:0:$longeur}
fi

cd $chemin
source ./2convertion/convert.sh "." $sens $thread
#source ./3-4-5dropseq/dropseq.sh $thread $Gref $lread $nming $nmint
#source ./4alignement/align.sh $thread $Gref $lread

cd $chemin

