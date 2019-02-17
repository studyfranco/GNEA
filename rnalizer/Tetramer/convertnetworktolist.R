#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)<2) {
  stop("At least 2 argument must be supplied.\n", call.=FALSE)
}

RegulomFolder <- "/home/studerf/mnt/Zone4/rnalizer/SCNorm/results/Ref.H9_SC.Orga3B_lfc.1_pval.0.01_Norm.Mean/SingleCell/ResultTetra/Reguloms"
outdir <- "/home/studerf/mnt/Zone2/Pipeline/SCNorm/results/Ref.H9_SC.Orga1A_lfc.1_pval.0.1_Norm.Mean/SingleCell/pval.0.05_lfc.1/ResultTetra/"

RegulomFolder <- args[1]
outdir <- args[2]

dir.create(outdir, showWarnings = FALSE)
dir.create(file.path(outdir,"RegulomListGenes"), showWarnings = FALSE)
listfileRegulom <- list.files(path = RegulomFolder, pattern=".tsv")

i <- 1
while (i <= length(listfileRegulom)){
  result <- read.table(file.path(RegulomFolder,listfileRegulom[i]), header = TRUE, sep = "\t")
  Col1 <- toupper(result[,1])
  Col2 <- toupper(result[,2])
  if (nrow(result) > 0){
    Col <- c(Col1,Col2)
    ListGenes <- matrix(data = Col,ncol = 1)
    colnames(ListGenes) <- c("Node")
    ListGenes <- ListGenes[!duplicated(ListGenes[,1,drop=FALSE]),1,drop=FALSE]
    write.table(ListGenes, file = file.path(file.path(outdir,"RegulomListGenes"),paste("ListGenesRegu.",substr(listfileRegulom[i],17,nchar(listfileRegulom[i])-4),".tsv", sep = "")),row.names = FALSE, quote = FALSE, sep='\t')
  }
  i <- i+1
}