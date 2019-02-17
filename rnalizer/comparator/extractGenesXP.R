#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)<7) {
  stop("At least five argument must be supplied.\n", call.=FALSE)
}
library(SummarizedExperiment)

Core <- 2
refdir <- "/home/studerf/mnt/Zone2/rnalizer/comparator/reference"
compdir <- "/home/studerf/mnt/Zone2/rnalizer/comparator/compar"
countdir <- "/home/studerf/mnt/Zone2/rnalizer/comparator/counts"
outdir <- "//home/studerf/mnt/Zone2/rnalizer/comparator/results/"
csvparam <- "/home/studerf/mnt/Zone2/rnalizer/comparator/param/XPMarco.csv" # Contain study param. Group are the param for comparaison. Group correspond a collumn in ComparFile or File (For compare allsample vs Reference)
## ReferenceFile  ComparFile   Group
## Study55Ref     Study55Comp  Cell

# Study55Comp contain Run Infos (* are obligatory + One group like cell)
##          * SampleName    cell   dex albut Run*        avgLength Experiment  Sample    BioSample    Organism*
## SampleName GSM1275862  N61311 untrt untrt SRR1039508       126  SRX384345  SRS508568 SAMN02422669  Human

# Study55Ref contain Run Infos (* are obligatory)
##          * SampleName    cell   dex albut Run*        avgLength Experiment  Sample    BioSample    Organism*
## SampleName GSM1275862  N61311 untrt untrt SRR1039508       126  SRX384345  SRS508568 SAMN02422669  Human

###############################################################
lfc = 1
pval = 0.01
###############################################################
#################################################################################
useAlpha <- FALSE # Choose if you want use padj for select good genes
alpha <- 0.01 # Threshold on the adjusted p-value (padj)
#################################################################################

csvparam <- args[1]
refdir <- args[2]
compdir <- args[3]
countdir <- args[4]
outdir <- args[5]
lfc <- as.numeric(args[6])
pval <- as.numeric(args[7])
Core <- as.numeric(args[8])


param <- read.csv(csvparam, header = TRUE)

references <- read.csv(file.path(refdir,paste(param$ReferenceFile[1],".csv", sep = "")),row.names = 1 , header = TRUE)

compars <- read.csv(file.path(compdir,paste(param$ComparFile[1],".csv", sep = "")),row.names = 1 , header = TRUE)
compars <- compars[order(compars[,as.vector(param$Group[1])]),]

outdirComp <- file.path(outdir,paste("Ref.",param$ReferenceFile[1],"Comp.",param$ComparFile[1],"Group.",param$Group[1],".lfc.",lfc,".pval.",pval, sep = ""))

i <- 1
listResultDESeq <- list()
j <- 1
while (i <= nrow(compars)){
  group <- as.character(compars[i,as.vector(param$Group[1])])
  
  outdirGroup <- file.path(outdirComp,group)
  DiffGenTable <- read.csv(file.path(outdirGroup,"Deseq.csv"), row.names = 1, header = TRUE)
  
  listResultDESeq[[j]] <- DiffGenTable
  #DiffGen <- DiffGenTable[DiffGenTable$log2FoldChange < -lfc | DiffGenTable$log2FoldChange > lfc, ,drop=FALSE]
  #DiffGen <- DiffGen[DiffGen$pvalue < pval , ,drop=FALSE]
  DiffGen <- DiffGenTable
  
  if (j == 1){
    geneselect <- as.matrix(rownames(DiffGen))
    listgroup <- c(group)
  } else {
    geneselect <- rbind(geneselect,as.matrix(rownames(DiffGen)))
    listgroup <- c(listgroup,group)
  }

  
  i <- i+1
  while (i <= nrow(compars) && group == as.character(compars[i,as.vector(param$Group[1])]) ){
    i <- i+1
  }
  j <- j+1
}

geneselect <- geneselect[!duplicated(geneselect[,1]),,drop=FALSE]

i <- 1
while (i <= length(listResultDESeq)){
  listResultDESeq[[i]] <- listResultDESeq[[i]][rownames(listResultDESeq[[i]]) %in% geneselect,6,drop=FALSE]
  colnames(listResultDESeq[[i]]) <- c(listgroup[i])
  i <- i+1
}

library(foreach)
library(iterators)
library(doParallel)
library(parallel)

cl <- makeCluster(Core)
registerDoParallel(cl)
while (length(listResultDESeq) > 1){
  nbjob <- as.integer(length(listResultDESeq)/2)
  results <- foreach(j = 1:nbjob) %dopar% {
    cellbool <- merge(listResultDESeq[[j*2-1]],listResultDESeq[[j*2]],all=TRUE,by="row.names")
    rownames(cellbool) <- cellbool[,1]
    cellbool <- cellbool[,-1,drop=FALSE]
    cellbool
  }
  if (length(listResultDESeq)%%2 > 0){
    listResultDESeq <- c(results,list(listResultDESeq[[nbjob*2+1]]))
  } else {
    listResultDESeq <- results
  }
}
stopCluster(cl)

results <- listResultDESeq[[1]]
results[is.na(results)] = 0

write.table(results, file = file.path(outdirComp,"lfcGenes.tsv"), quote = FALSE, sep='\t',col.names=NA)