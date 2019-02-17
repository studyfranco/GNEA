#!/bin/bash


nthread=$1
Gref=$2
lread=$3
nming=$4
nmint=$5

chemin=`pwd`

listebam=`ls $chemin/3-4-5dropseq/bam`
cd $chemin/3-4-5dropseq/soft
rm -rf $chemin/references/dropseq/$Gref/$Gref.dict
java -jar /home/studerf/Pipeline/3-4-5dropseq/soft/3rdParty/picard/picard.jar CreateSequenceDictionary R=$chemin/references/dropseq/$Gref/$Gref.fasta O=$chemin/references/dropseq/$Gref/$Gref.dict
for i in $listebam
do
	let "longeur=${#i}-4"
	nfile=${i:0:$longeur}
	rm -rf $chemin/3-4-5dropseq/alignbam/$nfile
	rm -rf $chemin/3-4-5dropseq/tempsdrop/$nfile
	mkdir $chemin/3-4-5dropseq/alignbam/$nfile
	mkdir $chemin/3-4-5dropseq/tempsdrop/$nfile
	source ./Drop-seq_alignment.sh -g $chemin/4alignement/genome/$Gref/$lread -r $chemin/references/dropseq/$Gref/$Gref.fasta -p -o $chemin/3-4-5dropseq/alignbam/$nfile -s $chemin/4alignement/STAR -t $chemin/3-4-5dropseq/tempsdrop/$nfile -T $nthread $chemin/3-4-5dropseq/bam/$i
	rm -rf $chemin/3-4-5dropseq/tempsdrop/$nfile
	rm -rf $chemin/3-4-5dropseq/bam/$i
	source ./DigitalExpression I=$chemin/3-4-5dropseq/alignbam/$nfile/star_gene_exon_tagged.bam O=$chemin/6nomalisation/matrix/$nfile/$nfile.dge.csv.gz SUMMARY=/home/studerf/Pipeline/6nomalisation/matrix/$nfile/$nfile.dge.summary.txt MIN_NUM_GENES_PER_CELL=$nming MIN_NUM_TRANSCRIPTS_PER_CELL=$nmint
done

cd $chemin