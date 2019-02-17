#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH -o slurm.%N.%j.AlignJobStar.out           # STDOUT
#SBATCH -e slurm.%N.%j.AlignJobStar.err           # STDERR


Sample=$4
readLength=$3
genome=$2
thred=$1

chemin=`pwd`
listfastq=`ls $chemin/4alignement/temp/fastq/${Sample}/`
fastq=""
nbbile=0

for nfile in $listfastq
do
	fastq="${fastq}${chemin}/4alignement/temp/fastq/${Sample}/${nfile} "
	nbfile=$(($nbfile + 1))
done

if [ ${nbfile} -eq 1 ]
then
	XP="Single"
elif [ ${nbfile} -eq 2 ]
then
	XP="Paired"
else
	echo "The number of file send are more than expected"
	exit 1
fi

mkdir -p $chemin/4alignement/temp/${Sample}

$chemin/4alignement/STAR --genomeDir $chemin/4alignement/genome/$genome/$readLength --readFilesIn ${fastq}\
						--runThreadN $thred --outFileNamePrefix $chemin/4alignement/temp/${Sample}/${Sample} \
						--outSAMtype BAM Unsorted --outTmpDir $chemin/4alignement/temp/${Sample}_star

source activate /shared/labo5/gronemeyer4/studerf/.conda/pln1R

Rscript --vanilla $chemin/4alignement/BamToCount.R $chemin/4alignement/temp/${Sample}/${Sample}Aligned.out.bam ${Sample} ${XP} \
											$chemin/references/annotation/${genome}.gtf $thred \
											$chemin/5normalization/counts

mv $chemin/4alignement/temp/fastq/${Sample} $chemin/Used/
mkdir $chemin/Used/${Sample}/Starout
mv $chemin/4alignement/temp/${Sample}/* $chemin/Used/${Sample}/Starout/
cp $chemin/5normalization/counts/${Sample}.csv $chemin/Used/${Sample}

rm -r $chemin/4alignement/temp/${Sample}
rm -r $chemin/4alignement/fastq/${Sample}

exit 0