#!/bin/bash

besoin=$2
thred=$3

chemin=`pwd`
listesra=`ls $1/2convertion/sra`

if [ "fastq" = $besoin ]
then
	for i in $listesra
	do
		$1/sratoolkit/bin/fastq-dump -O $1/3demulty/fastq/ $1/2convertion/sra/$i
	done 
elif [ "bamO" = $besoin ]
then
	for i in $listesra
	do
		let "longeur=${#i}-4"
		nfile=${i:0:$longeur}
		$1/sratoolkit/bin/sam-dump --output-file $1/2convertion/sam/$nfile.sam $1/2convertion/sra/$i
		$1/2convertion/samtools view -S -b -@ $thred $1/2convertion/sam/$nfile.sam > $1/2convertion/bam/$nfile.bam
		$1/2convertion/samtools sort -@ $thred $1/2convertion/bam/$nfile.bam -o $1/3-4-5dropseq/bam/$nfile.bam
		rm -rf $1/2convertion/sam/$nfile.sam
		rm -rf $1/2convertion/bam/$nfile.bam
	done 
elif [ "dropseqv1" = $besoin ]
then
	for i in $listesra
	do
		let "longeur=${#i}-4"
		nfile=${i:0:$longeur}
		$1/sratoolkit/bin/sam-dump --output-file $1/2convertion/sam/$nfile.sam $1/2convertion/sra/$i
		java -jar $chemin/3-4-5dropseq/soft/3rdParty/picard/picard.jar SortSam I=$chemin/2convertion/sam/$nfile.sam O=$chemin/3-4-5dropseq/bam/$nfile.bam SORT_ORDER=queryname
		rm -rf $1/2convertion/sam/$nfile.sam
	done
elif [ "dropseq" = $besoin ]
then
	echo "Convertion des fichier sra en bam pour dropseq"
	for i in $listesra
	do
		let "longeur=${#i}-4"
		nfile=${i:0:$longeur}
		rm -rf $1/2convertion/fastq/$nfile.fastq
		rm -rf $1/3-4-5dropseq/bam/$nfile.bam
		$1/sratoolkit/bin/fastq-dump -O $1/2convertion/fastq/ $1/2convertion/sra/$i
		java -jar $chemin/3-4-5dropseq/soft/3rdParty/picard/picard.jar FastqToSam F1=$chemin/2convertion/fastq/$nfile.fastq O=$chemin/3-4-5dropseq/bam/$nfile.bam SORT_ORDER=queryname SAMPLE_NAME=$nfile
		rm -rf $1/2convertion/fastq/$nfile.fastq
	done
fi
