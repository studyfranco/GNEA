#!/bin/bash
#
#SBATCH -t 7-00                    # time (D-HH:MM)
#SBATCH -o slurm.Tetramer.%N.%j.out           # STDOUT
#SBATCH -e slurm.Tetramer.%N.%j.err           # STDERR

headerMR=$1
headerGRN=$2
headerGO=$3
MRFolder=$4
GRNFolder=$5
GOFolder=$6
MatrixFile=$7
outdir=$8
core=$9

chemin=`pwd`

java -Xmx20g -XX:+UseConcMarkSweepGC -XX:-UseGCOverheadLimit -jar $chemin/Tetramer/Topology.jar -log10 -EGON -WGON -ETOH -WAHN -HMRN ${headerMR} -HGRN ${headerGRN} -HGO ${headerGO} -MRN ${MRFolder} -GRN ${GRNFolder} -GO ${GOFolder} -f ${MatrixFile} -out ${outdir}
Rscript --vanilla $chemin/Tetramer/GoExtractTopo.R $outdir/Topology/HubInformations/GRN $outdir/Topology/HubInformations/GRN_GOTerm 0.01 2 $core 1
Rscript --vanilla $chemin/Tetramer/GoExtractTopo.R $outdir/Topology/HubInformations/MR $outdir/Topology/HubInformations/MR_GOTerm 0.01 2 $core 1
java -jar -Xmx20g -XX:+UseConcMarkSweepGC -XX:-UseGCOverheadLimit $chemin/Tetramer/GOChildExtract.jar $outdir/Topology/HubNetwork.tsv $outdir/Topology/HubInformations/GRN_GOTerm $outdir/Topology/HubInformations/GRN_GOTerm GOTerm_
java -jar -Xmx20g -XX:+UseConcMarkSweepGC -XX:-UseGCOverheadLimit $chemin/Tetramer/GOChildExtract.jar $outdir/Topology/HubNetwork.tsv $outdir/Topology/HubInformations/MR_GOTerm $outdir/Topology/HubInformations/MR_GOTerm GOTerm_
exit 0