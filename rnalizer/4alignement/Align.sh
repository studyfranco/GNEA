#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH -o 4alignement/Log/slurm.%N.%j.AlignStar.out           # STDOUT
#SBATCH -e 4alignement/Log/slurm.%N.%j.AlignStar.err           # STDERR

genome=$2
ncore=$1


chemin=`pwd`
subdircount=`find $chemin/4alignement/fastq/ -maxdepth 1 -type d | wc -l`

if [ $subdircount -ne 1 ]
then
	listfastqdir=`ls -d $chemin/4alignement/fastq/*/`
	for fastqdir in $listfastqdir
	do
		listfile=`ls $fastqdir`
		for file in $listfile
		do
			readLengthtpm=`head ${fastqdir}${file} | grep length | cut -f3 -d' ' | cut -f2 -d'=' | uniq`
			
			if [[  $(echo "${readLengthtpm}" | wc -c) -ne 1  ]]
			then
				if [ ! -f $chemin/4alignement/genome/$genome/$readLengthtpm/SAindex ]
				then
					4alignement/initialisationStar.sh $ncore $genome $readLengthtpm
				fi
				readLength=${readLengthtpm}
			fi
		done
		mv ${fastqdir} $chemin/4alignement/temp/fastq/
		Sample=`echo "${fastqdir}" | rev | cut -f2 -d '/' | rev`
		sbatch -N 1 -n $ncore -t 7-00 --mem 40GB 4alignement/AlignJob.sh $ncore $genome $readLength $Sample
	done
fi

listfastq=`ls $chemin/4alignement/fastq/`
for file in $listfastq
do
	readLengthtpm=`head $chemin/4alignement/fastq/${file} | grep length | cut -f3 -d' ' | cut -f2 -d'=' | uniq`
	if [[  $(echo "${readLengthtpm}" | wc -c) -ne 1  ]]
	then
		if [ ! -f $chemin/4alignement/genome/$genome/$readLengthtpm/SAindex ]
		then
			4alignement/initialisationStar.sh $ncore $genome $readLengthtpm
		fi
		readLength=${readLengthtpm}
		Sample=`echo "${file}" | sed "s/.fastq//"`
		mkdir $chemin/4alignement/temp/fastq/${Sample}
		mv $chemin/4alignement/fastq/${file} $chemin/4alignement/temp/fastq/${Sample}
		sbatch -N 1 -n $ncore -t 7-00 --mem 40GB 4alignement/AlignJob.sh $ncore $genome $readLength $Sample
	fi
done

exit 0