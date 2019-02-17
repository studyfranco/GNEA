#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH -o slurm.%N.%j.initStar.out           # STDOUT
#SBATCH -e slurm.%N.%j.initStar.err           # STDERR


readLength=$3
genome=$2
thred=$1

let "lengthOverhang=$readLength - 1"
chemin=`pwd`


mkdir -p $chemin/4alignement/genome/$genome/$readLength

$chemin/4alignement/STAR --runMode genomeGenerate --genomeDir $chemin/4alignement/genome/$genome/$readLength \
							--genomeFastaFiles $chemin/references/genome/$genome/${genome}.fa --sjdbGTFfile $chemin/references/annotation/${genome}.gtf \
							--sjdbOverhang ${lengthOverhang} --runThreadN $thred --outTmpDir $chemin/4alignement/temp/genomegener_${genome}_$readLength
exit 0