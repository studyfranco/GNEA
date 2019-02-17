#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH -o 4alignement/Log/slurm.%N.%j.AlignManual.out           # STDOUT
#SBATCH -e 4alignement/Log/slurm.%N.%j.AlignManual.err           # STDERR

Sample2=$5
Sample1=$4
readLength=$3
genome=$2
thred=$1

chemin=`pwd`
fastq=""
ZCAT="--readFilesCommand zcat"

if [ ! $(echo "${Sample1}" | wc -c) -ne 1 ]
then
	echo "The number of file send are less than expected"
	exit 1
elif [ ! $(echo "${Sample2}" | wc -c) -ne 1 ]
then
	XP="Single"
	fastq="${Sample1} "
else
	XP="Paired"
	fastq="${Sample1} ${Sample2} "
fi

if [[  $(echo "${readLength}" | wc -c) -ne 1  ]]
then
	if [ ! -f $chemin/4alignement/genome/$genome/$readLength/SAindex ]
	then
		4alignement/initialisationStar.sh $ncore $genome $readLength
	fi
else
	echo "The read length are bad"
	exit 1
fi

gz=`echo "${Sample1}" | rev | cut -f1 -d '.' | rev`

if [ $gz == "gz" ]
then
	Sample=`echo "${Sample1}" | rev | cut -f1 -d '/' | rev | rev | cut -f3 -d '.' | rev`
	fastq="${fastq}${ZCAT} "
else
	Sample=`echo "${Sample1}" | rev | cut -f1 -d '/' | rev | rev | cut -f2 -d '.' | rev`
fi

mkdir -p $chemin/4alignement/temp/${Sample}

$chemin/4alignement/STAR --genomeDir $chemin/4alignement/genome/$genome/$readLength --readFilesIn ${fastq}\
						--runThreadN $thred --outFileNamePrefix $chemin/4alignement/temp/${Sample}/${Sample} --outFilterMultimapNmax 1 \
						--outSAMtype BAM SortedByCoordinate Unsorted --outTmpDir $chemin/4alignement/temp/${Sample}_star --outWigType wiggle --outWigNorm None

source activate /shared/labo5/gronemeyer4/studerf/.conda/pln1R

Rscript --vanilla $chemin/4alignement/BamToCount.R $chemin/4alignement/temp/${Sample}/${Sample}Aligned.out.bam ${Sample} ${XP} \
											$chemin/references/annotation/${genome}.gtf $thred \
											$chemin/5normalization/counts

mkdir $chemin/Used/${Sample}
mkdir $chemin/Used/${Sample}/Starout
mv $chemin/4alignement/temp/${Sample}/* $chemin/Used/${Sample}/Starout/
cp $chemin/5normalization/counts/${Sample}.csv $chemin/Used/${Sample}

rm -r $chemin/4alignement/temp/${Sample}
rm -r $chemin/4alignement/temp/${Sample}_star

exit 0