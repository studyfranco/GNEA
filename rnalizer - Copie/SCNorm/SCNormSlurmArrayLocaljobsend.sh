#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH --array=0-400%2
#SBATCH -o SCNorm/Log/slurm.SCNorm.%A_%a.out           # STDOUT
#SBATCH -e SCNorm/Log/slurm.SCNorm.%A_%a.err           # STDERR

paramfiles=$1
refdir=$2
compardir=$3
countdir=$4
resultdir=$5
NetworkFile=$6
lfc=$7
pval=$8
core=$9
method=${10}

chemin=`pwd`

source activate /shared/labo5/gronemeyer4/studerf/.conda/envs/rnalizer

paramfile=`awk "NR==${SLURM_ARRAY_TASK_ID}" ${paramfiles}`
if [ $(echo "${paramfile}" | wc -c) -ne 1 ]
then
	echo "SLURM_JOBID: " $SLURM_JOBID
	echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
	echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID
	echo "Parameter File:" $paramfile
	echo "Method:" $method
	XP=`sed -n "2{p;q}" $paramfile`
	ref=`echo "$XP" | cut -d"," -f1`
	SC=`echo "$XP" | cut -d"," -f2`
	dirXP="Ref.${ref}_SC.${SC}_lfc.${lfc}_pval.${pval}_Norm.${method}"

	Rscript --vanilla $chemin/SCNorm/scnorm.R $paramfile $refdir $compardir $countdir $resultdir $NetworkFile $lfc $pval $core $method

	./Tetramer/Tetramer.sh $NetworkFile $resultdir/$dirXP/SingleCell $lfc $core
fi

exit 0 