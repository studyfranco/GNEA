#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH -o slurm.Tetramer.%N.%j.out           # STDOUT
#SBATCH -e slurm.Tetramer.%N.%j.err           # STDERR


# source activate /shared/labo5/gronemeyer4/studerf/.conda/envs/rnalizer

network=$1
outdir=$2
lfc=$3
core=$4

chemin=`pwd`

hTetra="TG.Lfc"${lfc}"."
hMR="CoReg."${hTetra}
hGRN="regulom_"${hTetra}
MRFolder=${outdir}"/ResultTetra/CoRegNetwork"
GRNFolder=${outdir}"/ResultTetra/Reguloms"

mv $outdir/Tetrafiles/GoTerm $outdir/ResultTetra

python $chemin/Tetramer/similarityMatrix.py $outdir/Tetrafiles 1 $outdir/ResultTetra/similarityTetrafilesMatrix -sl 1 -c $core -mt tanimoto -ct 8

mv $outdir/ResultTetra/GoTerm $outdir/Tetrafiles

mv $outdir/ResultTetra/CoRegulListGenes/GoTerm $outdir/ResultTetra
mv $outdir/ResultTetra/CoRegulListGenes/Results_GOHub $outdir/ResultTetra

python $chemin/Tetramer/similarityMatrix.py $outdir/ResultTetra/CoRegulListGenes 1 $outdir/ResultTetra/similarityCoregulatoryMatrix -sl 1 -c $core -mt tanimoto -ct 14

mv $outdir/ResultTetra/GoTerm $outdir/ResultTetra/CoRegulListGenes
mv $outdir/ResultTetra/Results_GOHub $outdir/ResultTetra/CoRegulListGenes

python $chemin/Tetramer/similarityMatrix.py $outdir/ResultTetra/RegulomListGenes 1 $outdir/ResultTetra/similarityRegulomMatrix -sl 1 -c $core -mt tanimoto -ct 14

coring=$(($core/5))

hGO="GOTerm_"${hTetra}
GOFolder=${outdir}"/Tetrafiles/GoTerm/GoTermUP"
MatrixFile=${outdir}"/ResultTetra/similarityTetrafilesMatrix_tanimoto.tsv"
outdirTopo=${outdir}"/ResultTetra/Topology.DiffGene.UP"
$chemin/Tetramer/Topology.sh $hMR $hGRN $hGO $MRFolder $GRNFolder $GOFolder $MatrixFile $outdirTopo $coring &

hGO="GOTerm_"${hTetra}
GOFolder=${outdir}"/Tetrafiles/GoTerm/GoTermALL"
MatrixFile=${outdir}"/ResultTetra/similarityTetrafilesMatrix_tanimoto.tsv"
outdirTopo=${outdir}"/ResultTetra/Topology.DiffGene.ALL"
$chemin/Tetramer/Topology.sh $hMR $hGRN $hGO $MRFolder $GRNFolder $GOFolder $MatrixFile $outdirTopo $coring &

hGO="GOTerm_"${hTetra}
GOFolder=${outdir}"/Tetrafiles/GoTerm/GoTermDown"
MatrixFile=${outdir}"/ResultTetra/similarityTetrafilesMatrix_tanimoto.tsv"
outdirTopo=${outdir}"/ResultTetra/Topology.DiffGene.DOWN"
$chemin/Tetramer/Topology.sh $hMR $hGRN $hGO $MRFolder $GRNFolder $GOFolder $MatrixFile $outdirTopo $coring &

regul=`ls -a $outdir/ResultTetra/Reguloms | sed -e "/\.$/d" | wc -l`
if [ $regul -gt 0 ]
then
	hGO="GOTerm_"${hGRN}
	GOFolder=${outdir}"/ResultTetra/Reguloms/GoTerm"
	MatrixFile=${outdir}"/ResultTetra/similarityRegulomMatrix_tanimoto.tsv"
	outdirTopo=${outdir}"/ResultTetra/Topology.Regulom"

	$chemin/Tetramer/Topology.sh $hMR $hGRN $hGO $MRFolder $GRNFolder $GOFolder $MatrixFile $outdirTopo $coring &
fi

coreg=`ls -a $outdir/ResultTetra/CoRegulListGenes | sed -e "/\.$/d" | wc -l`
if [ $coreg -gt 0 ]
then
	hGO="GOTerm_CoReguloGenes."
	GOFolder=${outdir}"/ResultTetra/CoRegulListGenes/GoTerm"
	MatrixFile=${outdir}"/ResultTetra/similarityCoregulatoryMatrix_tanimoto.tsv"
	outdirTopo=${outdir}"/ResultTetra/Topology.Coreg"

	$chemin/Tetramer/Topology.sh $hMR $hGRN $hGO $MRFolder $GRNFolder $GOFolder $MatrixFile $outdirTopo $coring &
fi

wait