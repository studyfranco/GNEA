#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# SingleCellNorm version 2.0
#
#- Contain a collection of functions for compare a single cell run to a bulk RNA.   
#- It is the sample comparison step. It will process single counts file to create network and a differential expressed gene list
#- You need a classical RNA-seq reference
#- impovements of the version 2: - Parallelisation treatement of the cells.
#-                               - Unused function are remove.
#-                               - Capacity to choose single cell bulk calculation. "Mean" or "Sums".
#-                               - Comment the code.

if (length(args) != 10) {
  stop("At least 10 argument must be supplied.\n", call.=FALSE)
}
library(SummarizedExperiment)

CellnetFile <- "/home/studerf/mnt/Zone2/Pipeline/SCNorm/Human_Big_GRN_032014.csv"
refdir <- "/home/studerf/mnt/Zone2/"
SCdir <- "/home/studerf/mnt/Zone2/"
countdir <- "/home/studerf/mnt/Zone2/counts"
outdir <- "/home/studerf/mnt/Zone2/"
method <- "Mean"
Core <- 6
csvparam <- "/home/studerf/mnt/Zone2/param7.csv" # Contain study param. Group are the param for comparaison. Group correspond a collumn in ComparFile or File (For compare allsample vs Reference)
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
SCdir <- args[3]
countdir <- args[4]
outdir <- args[5]
CellnetFile <- args[6]
lfc <- as.numeric(args[7])
pval <- as.numeric(args[8])
Core <- as.numeric(args[9])
method <- args[10]

#################################################################################################################################
#################################### Graphic Function for see Normalisation effects #############################################
#################################################################################################################################

## scatterplot, this fonction create 2 scattterplot per sample. 1 with raw counts, 2 with norm counts.
##            Takes in argument :
##            data.frame : rawcounts   Raw counts. Each column name are used for the sample name.
##            data.frame : normcounts  Norm counts. Each column name are used for the sample name.
##            text : outdir            Directory where the graphic are saved.
## Return : void
scatterplot <- function(rawcount, normcount, outdir){
  library(dplyr)
  library(ggplot2)
  
  # The First scatterplot for see the normalisation count weight
  i <- 2
  while (i <= ncol(normcount)) {
    png(file.path(outdir,paste(colnames(normcount)[i],"scatterplot-normal.png",sep = "")), 1200, 1000, pointsize=20)
    df <- bind_rows(
      as_data_frame(log2(normcount[, c(1,i)]+1)) %>%
        mutate(transformation = "log2(Normalised Count + 1)"))
    colnames(df)[1:2] <- c("x", "y")  
    p <- ggplot(df, aes(x = x, y = y)) + geom_hex(bins = 80) +
      coord_fixed() + facet_grid( . ~ transformation) + geom_smooth(method='gam', size = 1.25, color = "yellow") + geom_smooth(method='auto', size = 0.5, color = "red") + geom_smooth(span = 0.01, color = "green", size = 0.25) + labs(x = colnames(normcount)[1]) + labs(y = colnames(normcount)[i])
    print(p)
    dev.off()
    i <- i+1
  }
  
  # The second scatterplot for see the raw count weight
  i <- 2
  while (i <= ncol(rawcount)) {
    png(file.path(outdir,paste(colnames(rawcount)[i],"scatterplot-rawcount.png",sep = "")), 1200, 1000, pointsize=20)
    df <- bind_rows(
      as_data_frame(log2(rawcount[, c(1,i)]+1)) %>%
        mutate(transformation = "log2(Raw Count + 1)"))
    colnames(df)[1:2] <- c("x", "y")  
    p <- ggplot(df, aes(x = x, y = y)) + geom_hex(bins = 80) +
      coord_fixed() + facet_grid( . ~ transformation) + geom_smooth(method='gam', size = 1.25, color = "yellow") + geom_smooth(method='auto', size = 0.5, color = "red") + geom_smooth(span = 0.01, color = "green", size = 0.25) + labs(x = colnames(rawcount)[1]) + labs(y = colnames(rawcount)[i])
    print(p)
    dev.off()
    i <- i+1
  }
}

## MAPlot, this fonction create 2 MAPlot per sample. 1 with raw counts, 2 with norm counts.
##            Takes in argument :
##            data.frame : rawcounts   Raw counts
##            data.frame : normcounts  Norm counts
##            text : outdir            Directory where the graphic are saved
## Return : void
MAPlot <- function(rawcount, normcount, outdir){
  
  # The First MA Plot for see the normalisation count weight
  i <- 2
  while (i <= ncol(normcount)) {
    png(file.path(outdir,paste(colnames(normcount)[i],"MvA Plot Normalised Count",sep = "")), 1200, 1000, pointsize=20)
    mvaDF <- data.frame(log2(sqrt((normcount[,1])*(normcount[,i]))),log2((normcount[,i]+0.001)/(normcount[,1]+0.001)))
    p <- plot(mvaDF,pch=20, cex=0.3,main=paste("MA plot ",colnames(normcount)[1],"VS",colnames(normcount)[i]," normalised count",sep = ""), xlab=paste("Log2(sqrt(",colnames(normcount)[1],"*",colnames(normcount)[i],")",sep = ""), ylab=paste("log2(",colnames(normcount)[i],"/",colnames(normcount)[1],")",sep = ""), col="blue")
    print(p)
    abline(h = c(-1, 1), col = "brown", lwd=3)
    abline(h = 0, col = "black", lwd=3)
    selected <- !is.infinite(mvaDF[,1])
    mvaDF <- mvaDF[selected,]
    selected <- !is.infinite(mvaDF[,2])
    mvaDF <- mvaDF[selected,]
    abline(lm(mvaDF[,2] ~ mvaDF[,1]), col = "red", lwd=3)
    lines(predict(loess(mvaDF[,2] ~ mvaDF[,1], span=0.1)), col = "green", lwd=2)
    dev.off()
    i <- i+1
  }
  
  # The second MA Plot for see the raw count weight
  i <- 2
  while (i <= ncol(rawcount)) {
    png(file.path(outdir,paste(colnames(rawcount)[i],"MvA Plot Raw Count",sep = "")), 1200, 1000, pointsize=20)
    mvaDF <- data.frame(log2(sqrt((rawcount[,1])*(rawcount[,i]))),log2((rawcount[,i]+0.001)/(rawcount[,1]+0.001)))
    p <- plot(mvaDF,pch=20, cex=0.3,main=paste("MA plot ",colnames(rawcount)[1],"VS",colnames(rawcount)[i]," raw count",sep = ""), xlab=paste("Log2(sqrt(",colnames(rawcount)[1],"*",colnames(rawcount)[i],")",sep = ""), ylab=paste("log2(",colnames(rawcount)[i],"/",colnames(rawcount)[1],")",sep = ""), col="blue")
    print(p)
    abline(h = c(-1, 1), col = "brown", lwd=3)
    abline(h = 0, col = "black", lwd=3)
    selected <- !is.infinite(mvaDF[,1])
    mvaDF <- mvaDF[selected,]
    selected <- !is.infinite(mvaDF[,2])
    mvaDF <- mvaDF[selected,]
    abline(lm(mvaDF[,2] ~ mvaDF[,1]), col = "red", lwd=3)
    lines(predict(loess(mvaDF[,2] ~ mvaDF[,1], span=0.1)), col = "green", lwd=2)
    dev.off()
    i <- i+1
  }
}

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################

#################################################################################################################################
################################## Function Graphic after Deseq 2 Annalyse ######################################################
#################################################################################################################################

## volcanoplot2, this fonction create 1 Volcano plot.
##            Takes in argument :
##            deseq2.results : res   A object deseq2 who contain result()
##            numeric : lfc      Minimum significatif lfc
##            numeric : pvalue   Minimum significatif pvalue
##            text : outdir      Directory where the graphic are saved
## Return : void
volcanoplot2 <- function(res, lfc, pvalue, useAlpha, alpha, outdir){
  res.DESeq2 <- res
  png(file.path(outdir,"diffexpr-volcanoplot2.png"), 1200, 1000, pointsize=20)
  
  #Convertion of the p-value
  tab = data.frame(logFC = res$log2FoldChange, negLogPval = -log10(res$pvalue))
  par(mar = c(5, 4, 4, 4))
  plot(tab, pch = 16, cex = 0.6, xlab = expression(log[2]~fold~change), ylab = expression(-log[10]~pvalue))
  
  #Selection the significant genes
  if (useAlpha){
    signGenes = (abs(res.DESeq2$log2FoldChange) > lfc & !is.na(res.DESeq2$padj) & res.DESeq2$padj < alpha & res.DESeq2$pvalue < pval)
  } else{
    signGenes = (abs(res.DESeq2$log2FoldChange) > lfc & res.DESeq2$pvalue < pval)
  }
  
  #Print in a another color the significant points
  points(tab[signGenes, ], pch = 16, cex = 0.8, col = "red") 
  abline(h = -log10(pval), col = "green3", lty = 2, lwd=3) 
  abline(v = c(-lfc, lfc), col = "blue", lty = 2, lwd=3) 
  mtext(paste("pval =", pval), side = 4, at = -log10(pval), cex = 0.8, line = 0.5, las = 1) 
  mtext(c(paste("-", lfc, "fold"), paste("+", lfc, "fold")), side = 3, at = c(-lfc, lfc), cex = 0.8, line = 0.5)
  dev.off()
}

## volcanoplot1, this fonction create 1 Volcano plot.
##            Takes in argument :
##            deseq2.results : res   A object deseq2 who contain result()
##            numeric : lfc      Minimum significatif lfc
##            numeric : pvalue   Minimum significatif pvalue
##            text : outdir      Directory where the graphic are saved
## Return : void
volcanoplot1 <- function(res, lfc, pvalue, useAlpha, alpha, outdir){
  png(file.path(outdir,"diffexpr-volcanoplot.png"), 1200, 1000, pointsize=20)
  res.DESeq2 <- res
  #Extract the column names
  cols <- densCols(res.DESeq2$log2FoldChange, -log10(res.DESeq2$pvalue))
  plot(res.DESeq2$log2FoldChange, -log10(res.DESeq2$padj), col=cols, panel.first=grid(),
       main="Volcano plot", xlab="Effect size: log2(fold-change)", ylab="-log10(adjusted p-value)",
       pch=20, cex=0.6)
  abline(v=0)
  abline(v=c(-lfc, lfc), col="brown", lwd=3)
  mtext(paste("padj =", alpha), side = 4)
  abline(h=-log10(alpha), col="brown", lwd=3)
  
  #Selection the significant genes
  if (useAlpha){
    signGenes = (abs(res.DESeq2$log2FoldChange) > lfc & !is.na(res.DESeq2$padj) & res.DESeq2$padj < alpha & res.DESeq2$pvalue < pval)
  } else{
    signGenes = (abs(res.DESeq2$log2FoldChange) > lfc & res.DESeq2$pvalue < pval)
  }
  valu = data.frame(res.DESeq2$log2FoldChange,-log10(res.DESeq2$padj))
  
  #Print in a another color the significant points
  points(valu[signGenes, ], pch = 20, cex = 0.6, col = "red")
  dev.off()
}

## MAPlotG, this fonction create 1 Volcano plot.
##            Takes in argument :
##            deseq2.results : res   A object deseq2 who contain result()
##            text : outdir      Directory where the graphic are saved
## Return : void
MAPlotG <- function(res, outdir){
  png(file.path(outdir,"General MA-plot.png"), 1200, 1000, pointsize=20)
  plotMA(res, colNonSig = "blue")
  abline(h=c(-1:1), col="red")
  topGene <- rownames(res)[which.min(res$padj)]
  with(res[topGene, ], {
    points(baseMean, log2FoldChange, col="dodgerblue", cex=2, lwd=2)
    text(baseMean, log2FoldChange, topGene, pos=2, col="dodgerblue")
  })
  dev.off()
}

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################

#################################################################################################################################
################################ Function Graphic after single cell normalisation ###############################################
#################################################################################################################################

## volcanoplot3, this fonction create 1 Volcano plot.
##            Takes in argument :
##            data.frame : tot   First column are lfc, the second are the pvalue for each genes for bulk
##            data.frame : cell  First column are lfc, the second are the pvalue for each genes for cell
##            numeric : lfc      Minimum significatif lfc
##            numeric : pvalue   Minimum significatif pvalue
##            text : outdir      Directory where the graphic are saved
## Return : void
volcanoplot3 <- function(tot, cell, lfc, pval, outdir){
  png(file.path(outdir,"diffexpr-volcanoplot3.png"), 1200, 1000, pointsize=20)
  
  #Convertion of the p-value
  tab = data.frame(logFC = tot[,1,drop=FALSE], negLogPval = -log10(tot[,2,drop=FALSE]))
  tab2 = data.frame(logFC = cell[,1,drop=FALSE], negLogPval = -log10(cell[,2,drop=FALSE]))
  
  par(mar = c(5, 4, 4, 4))
  plot(tab, pch = 16, cex = 0.6, xlab = expression(log[2]~fold~change), ylab = expression(-log[10]~pvalue))
  points(tab2, pch = 14, cex = 0.4,col = "green")
  
  #Selection the significant genes
  signGenes = (abs(tot[,1,drop=FALSE]) > lfc & tot[,2,drop=FALSE] < pval)
  signGenes2 = (abs(cell[,1,drop=FALSE]) > lfc & cell[,2,drop=FALSE] < pval)
  
  #Print in a another color the significant points
  points(tab[signGenes, ], pch = 16, cex = 0.8, col = "red")
  points(tab2[signGenes2, ], pch = 14, cex = 0.5, col = "blue") 
  
  
  abline(h = -log10(pval), col = "green3", lty = 2, lwd=3) 
  abline(v = c(-lfc, lfc), col = "blue", lty = 2, lwd=3) 
  mtext(paste("pval =", pval), side = 4, at = -log10(pval), cex = 0.8, line = 0.5, las = 1)
  mtext(c(paste("-", lfc, "fold"), paste("+", lfc, "fold")), side = 3, at = c(-lfc, lfc), cex = 0.8, line = 0.5)
  mtext(paste("Number Gene Select", sum(signGenes2)), side = 3, at = max(tab[,2]), cex = 0.8, line = 0.5, las = 1) 
  dev.off()
}

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################

#################################################################################################################################
####################################### Function for import counts ##############################################################
#################################################################################################################################

## GRCh37IDandSymbol, this fonction call grch37.ensemble.org for take Ensembl ID <=> Gene Symbol of GRCh37.
##            Takes no argument.
## Return : A data.frame with two column "ensembl_gene_id" "hgnc_symbol".
GRCh37IDandSymbol <- function(){
  library(biomaRt)
  #If the site of GRCh37 are down you can use the primary site with the recent ID.
  #ensembl54 <- useMart(host='http://www.ensembl.org', 
  #                     biomart='ENSEMBL_MART_ENSEMBL', 
  #                     dataset='hsapiens_gene_ensembl')
  ensembl54 <- useMart(host='http://grch37.ensembl.org', 
                       biomart='ENSEMBL_MART_ENSEMBL', 
                       dataset='hsapiens_gene_ensembl')
  #If the site of GRCh37 are down you can use the archive site.
  #ensembl54 <- useMart(host='feb2014.archive.ensembl.org', 
  #                     biomart='ENSEMBL_MART_ENSEMBL', 
  #                     dataset='hsapiens_gene_ensembl')
  #This varaible are the field, we want.
  attributes=c('ensembl_gene_id','hgnc_symbol')
  #Finaly, we get the informations.
  G_list<- getBM(attributes=attributes, values="*",
                 mart=ensembl54, uniqueRows=T)
  return(G_list)
}

## ConvertEnsemblIDtoSymbol, this fonction convert Ensembl ID to a Gene Symbol. You loose genes with no ensemble ID or with multiple gene symbol.
##                           It print when it cut duplicate.
##            Takes in argument :
##            data.frame : dataCounts   rownames are the ensembl ID, with one column who contain counts.
##            data.frame : IDlist  It's obatain with the GRCh37IDandSymbol function. It have two column "ensembl_gene_id" and "hgnc_symbol".
## Return : A data.frame with rownames are the genes symbol, and one column who contain counts.
ConvertEnsemblIDtoSymbol <- function(dataCounts,IDlist){
  dataCountsUP <- merge(dataCounts,IDlist,by.y="ensembl_gene_id", by.x="row.names")
  dataCountsUP <- dataCountsUP[(dataCountsUP$hgnc_symbol != ""),,drop=FALSE]
  ensemblDuplicate <- dataCountsUP[duplicated(dataCountsUP[,1:2]),]
  dataCountsUP <- dataCountsUP[!duplicated(dataCountsUP[,1:2]),2:3]
  symbolDuplicate <- dataCountsUP[duplicated(dataCountsUP$hgnc_symbol),]
  
  #dataCountsUP <- aggregate(. ~ hgnc_symbol,data=dataCountsUP,sum)
  #dataCounts <- dataCountsUP[,2,drop=FALSE]
  
  dataCountsUP <- dataCountsUP[!duplicated(dataCountsUP$hgnc_symbol),]
  dataCounts <- dataCountsUP[,1,drop=FALSE]
  
  rownames(dataCounts) <- dataCountsUP$hgnc_symbol
  
  print("EnsemblID with two Gene Symbol")
  print(ensemblDuplicate)
  print("Gene Symbol duplicated")
  print(symbolDuplicate)
  return(dataCounts)
}

## fusionCounts, this fonction merge two data frame by rownames. In a first time it upscale rownames. After it merge and remove unmerged genes.
##            Takes in argument :
##            data.frame : dataCounts
##            data.frame : dataCounts2
## Return : A data.frame with merge rownames, and merge column who contain counts.
fusionCounts <- function(dataCounts,dataCounts2){
  
  dataCounts <- dataCounts[!duplicated(toupper(rownames(dataCounts))),,drop=FALSE]
  dataCounts2 <- dataCounts2[!duplicated(toupper(rownames(dataCounts2))),,drop=FALSE]
  
  rownames(dataCounts) <- toupper(rownames(dataCounts))
  rownames(dataCounts2) <- toupper(rownames(dataCounts2))
  newDFCount <- merge(dataCounts,dataCounts2,by="row.names")
  namerow <- newDFCount[,1]
  newDFCount <- newDFCount[,-1]
  rownames(newDFCount) <- namerow
  return(newDFCount)
}

## runImport, import counts and take a name for the sample. It can be differenciate on the results files.
##            Takes in argument :
##            data.frame : DFimport  This datafram contain one column Run. This one are used for import counts csv.
##            text : countdir      Directory where the run are saved
##            text : sampleType    Name of the type of counts. It can be anything. It's just for find the sample and Reference counts in final files.
## Return : A data.frame with genes symbol rownames, and merge column who contain counts.
## This function call :
##           GRCh37IDandSymbol
##           ConvertEnsemblIDtoSymbol
##           fusionCounts
runImport <- function(DFimport,countdir,sampleType){
  IDlist <- GRCh37IDandSymbol()
  dataCounts <- read.csv(file.path(countdir,paste(DFimport$Run[1],".csv", sep = "")),row.names = 1 , header = TRUE)
  if (all(grepl("ENSG*",rownames(dataCounts),perl=TRUE))){
    dataCounts <- ConvertEnsemblIDtoSymbol(dataCounts,IDlist)
  }
  colnames(dataCounts) <- c(paste0(sampleType,".1.",colnames(dataCounts)))
  i <- 2
  while (i <= nrow(DFimport)){
    dataCounts2 <- read.csv(file.path(countdir,paste(DFimport$Run[i],".csv", sep = "")),row.names = 1 , header = TRUE)
    if (all(grepl("ENSG*",rownames(dataCounts2),perl=TRUE))){
      dataCounts2 <- ConvertEnsemblIDtoSymbol(dataCounts2,IDlist)
    }
    colnames(dataCounts2) <- c(paste0(sampleType,".",i,".",colnames(dataCounts2)))
    dataCounts <- fusionCounts(dataCounts,dataCounts2)
    i <- i+1
  }
  return(dataCounts)
}

## GenerColdata,
##            Takes in argument :
##            data.frame : dataCounts  This datafram contain one column Run. This one are used for import counts csv.
##            text : grp      Directory where the run are saved
## Return : A data.frame with genes symbol rownames, and merge column who contain counts.
GenerColdata <- function(dataCounts,grp){
  group <- rep(grp,ncol(dataCounts))
  coldata <- data.frame(group)
  rownames(coldata) <- colnames(dataCounts)
  return(coldata)
}

## GenerCellName, 
##            Takes in argument :
##            vector : cellnames      Directory where the run are saved
##            text : namesample   
##            text : outdir 
## Return : A data.frame with genes symbol rownames, and merge column who contain counts.
GenerCellName <- function(cellnames,namesample,outdir){
  GenericName <- c(paste(namesample,".c.1",sep=""))
  i <- 2
  while( i <= length(cellnames)){
    GenericName <- c(GenericName,paste(namesample,".c.",i,sep=""))
    i <- i+1
  }
  index <- data.frame(cellnames,GenericName)
  write.table(index, file = file.path(outdir,"Reference.cell.tsv"), quote = FALSE, sep='\t',row.names=FALSE)
  return(GenericName)
}

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################

#################################################################################################################################
######################################## Functions used to create a basic network ###############################################
#################################################################################################################################

CellnetExtract <- function(DiffGenFile, CellnetFile, outdirXP, lfc, pval){
  
  CellnetTable <- read.csv(CellnetFile, header = TRUE)
  CellnetTable$TG <- toupper(CellnetTable$TG)
  DiffGenTable <- read.csv(DiffGenFile, row.names = 1, header = TRUE)
  
  DiffGenTable[ is.na(DiffGenTable)] = 0
  # DiffGenTable[ is.nan(DiffGenTable)] = 0
  # DiffGenTable[ is.infinite(DiffGenTable)] = 0
  DiffGenTable <- DiffGenTable[DiffGenTable$log2FoldChange < -lfc | DiffGenTable$log2FoldChange > lfc, ,drop=FALSE]
  DiffGenTable <- DiffGenTable[DiffGenTable$pvalue < pval , ,drop=FALSE]
  if (nrow(DiffGenTable) <= 5000){
    CellnetExt2 <- merge(CellnetTable,DiffGenTable[,c(6,9) ,drop=FALSE],by.x="TG", by.y="row.names")
  } else {
    CellnetExt2 <- merge(CellnetTable,DiffGenTable[1:5000,c(6,9) ,drop=FALSE],by.x="TG", by.y="row.names")
    i <- 5000
    while(i < nrow(DiffGenTable)){
      k <- i+1
      i <- i+5000
      if (i > nrow(DiffGenTable)){
        i <- nrow(DiffGenTable)
      }
      CellnetExtTemps <- merge(CellnetTable,DiffGenTable[k:i,c(6,9) ,drop=FALSE],by.x="TG", by.y="row.names")
      CellnetExt2 <- rbind(CellnetExt2,CellnetExtTemps)
    }
  }
  CellnetExt <- CellnetExt2[,-8]
  CellnetExt <- CellnetExt[,-7]
  colnames(CellnetExt2)[c(7,8)] <- c("log2FoldChange","pvalue")
  # write.csv(CellnetExt, file = file.path(outdirXP,paste("CellnetExt.Lfc",lfc,".pvalue",pval,".csv", sep = "")), row.names=FALSE)
  write.csv(CellnetExt2, file = file.path(outdirXP,paste("CellnetExtEnrch.Lfc",lfc,".pvalue",pval,".csv", sep = "")), row.names=FALSE)
  write.csv(DiffGenTable[,c(6,9) ,drop=FALSE], file = file.path(outdirXP,paste("GeneSelect.lfc",lfc,".pvalue",pval,".csv", sep = "")), quote = FALSE)
  #write.csv(DiffGenTable[,6 ,drop=FALSE], file = file.path(outdirXP,paste("GeneSelect2.lfc",lfc,".pvalue",pval,".csv", sep = "")), quote = FALSE)
}

CellnetCellExtract <- function(CellDiffGenTable, CellnetFile, outdirXP, lfc, TableLfcPval, pval, valcounts, Core){
  library(foreach)
  library(iterators)
  library(doParallel)
  library(parallel)
  
  stepLFC <- 0.02
  
  CalculPvalCellV1 <- function(lfc, TableLfcPval, valcounts){
    points1 <- TableLfcPval[TableLfcPval[,1,drop=FALSE] >= lfc,]
    points2 <- TableLfcPval[TableLfcPval[,1,drop=FALSE] <= lfc,]
    
    points1 <- points1[order(abs(points1[,1,drop=FALSE]-lfc)),]
    points2 <- points2[order(abs(points2[,1,drop=FALSE]-lfc)),]
    
    points <- rbind(points1[1:5,,drop=FALSE],points2[1:5,,drop=FALSE])
    
    #points <- TableLfcPval[order(abs(TableLfcPval[,1,drop=FALSE]-lfc)),]
    #points <- points[1:100,,drop=FALSE]
    
    model <- lm(pvalue ~ log2FoldChange, data = points)
    dflfc <- as.data.frame(lfc)
    colnames(dflfc) <- c("log2FoldChange")
    pval <- predict(model,dflfc)
    pval <- pval/(abs(log2(abs(valcounts[1,1]-valcounts[1,2]+1)))/(abs(lfc)+1))
    return(pval)
  }
  
  CalculPvalCell <- function(lfc, TableLfcPval, echant, gap){
    points3 <- TableLfcPval[TableLfcPval[,1,drop=FALSE] >= (lfc-gap) & TableLfcPval[,1,drop=FALSE] <= (lfc+gap),]
    TableLfcPval <- TableLfcPval[TableLfcPval[,1,drop=FALSE] < (lfc-gap) | TableLfcPval[,1,drop=FALSE] > (lfc+gap),]
    points1 <- TableLfcPval[TableLfcPval[,1,drop=FALSE] > lfc+gap,]
    points2 <- TableLfcPval[TableLfcPval[,1,drop=FALSE] < lfc-gap,]
    
    points1 <- points1[order(abs(points1[,1,drop=FALSE]-lfc)),]
    points2 <- points2[order(abs(points2[,1,drop=FALSE]-lfc)),]
    
    points <- rbind(points1[1:5,,drop=FALSE],points3,points2[1:5,,drop=FALSE])
    
    model <- lm(pvalue ~ log2FoldChange, data = points)
    dflfc <- as.data.frame(echant[,1])
    colnames(dflfc) <- c("log2FoldChange")
    pvalue <- predict(model,dflfc)
    basePvalue <- pvalue
    i <- 1
    while (length(pvalue) > i){
      pvalue[i] <- pvalue[i]/(abs(log2(abs(echant[i,2]-echant[i,3])+1))/(abs(echant[i,1])+1))
      i <- i+1
    }
    
    celllfc <- cbind(echant[,1,drop=FALSE],pvalue,basePvalue)
    return(celllfc)
  }
  
  dir.create(file.path(outdirXP,"Network"), showWarnings = FALSE)
  dir.create(file.path(outdirXP,"Tetrafiles"), showWarnings = FALSE)
  dir.create(file.path(outdirXP,"Controle"), showWarnings = FALSE)
  dir.create(file.path(outdirXP,"Genes_not_found"), showWarnings = FALSE)
  
  CellnetTable <- read.csv(CellnetFile, header = TRUE)
  CellnetTable$TG <- toupper(CellnetTable$TG)
  
  cl <- makeCluster(Core)
  registerDoParallel(cl)
  # CellDiffGenTable[ is.na(CellDiffGenTable)] = 0
  #j <- 1
  #while(j <= ncol(CellDiffGenTable)){ 
  results <- foreach(j = 1:ncol(CellDiffGenTable)) %dopar% {
    celllfc <- CellDiffGenTable[,j,drop=FALSE]
    celllfc <- celllfc[!is.infinite(as.matrix(celllfc[,1,drop=FALSE])),,drop=FALSE]
    # CellDiffGenTable[ is.nan(CellDiffGenTable)] = 0
    # CellDiffGenTable[ is.infinite(CellDiffGenTable)] = 0
    
    celllfc <- celllfc[celllfc[,1] < -lfc | celllfc[,1] > lfc, ,drop=FALSE]
    # celllfc <- celllfc[order(celllfc[,1],decreasing=TRUE),,drop=FALSE]
    
    #i <- 1
    #pvalue <- CalculPvalCell(as.numeric(celllfc[i,1]), TableLfcPval, valcounts[rownames(valcounts) == rownames(celllfc)[i],c(1,j+1),drop=FALSE])
    #while( i < nrow(celllfc)){
    #  i <- i+1
    #  val <- CalculPvalCell(as.numeric(celllfc[i,1]), TableLfcPval, valcounts[rownames(valcounts) == rownames(celllfc)[i],c(1,j+1),drop=FALSE])
    #  pvalue <- c(pvalue,val)
    #}
    
    #pvalue <- foreach(i=1:nrow(celllfc), .combine='c') %dopar% {
    #  CalculPvalCell(as.numeric(celllfc[i,1]), TableLfcPval, valcounts[rownames(valcounts) == rownames(celllfc)[i],c(1,j+1),drop=FALSE])
    #}
    
    #namerow <- rownames(celllfc)
    #celllfc <- cbind(celllfc,pvalue)
    #rownames(celllfc) <- namerow
    
    namecol <- colnames(celllfc)
    counts <- valcounts[,c(1,j+1),drop=FALSE]
    cell <- merge(celllfc,counts,by="row.names")
    rownames(cell) <- cell[,1]
    cell <- cell[,-1,drop=FALSE]
    colnames(cell)[1] <- namecol
    
    i <- lfc
    element <- 0
    l <- list()
    gap <- stepLFC/2
    while( i <= max(celllfc)){
      i <- i+gap
      echant <- cell[cell[,1,drop=FALSE] >= (i-gap) & cell[,1,drop=FALSE] < (i+gap),,drop=FALSE]
      if (nrow(echant)>0){
        element <- element+1
        l[[element]] <- CalculPvalCell(i, TableLfcPval, echant, gap)
      }
      i <- i+gap
    }
    
    i <- -lfc
    while( i >= min(celllfc)){
      i <- i-gap
      echant <- cell[cell[,1,drop=FALSE] <= (i+gap) & cell[,1,drop=FALSE] > (i-gap),,drop=FALSE]
      if (nrow(echant)>0){
        element <- element+1
        l[[element]] <- CalculPvalCell(i, TableLfcPval, echant, gap)
      }
      i <- i-gap
    }
    
    newlfc <- l[[1]]
    i <- 2
    while( i <= element){
      newlfc <- rbind(newlfc,l[[i]])
      i <- i+1
    }
    
    celllfc <- newlfc
    
    write.csv(merge(celllfc,valcounts[,c(1,j+1),drop=FALSE],by="row.names"), file = file.path(file.path(outdirXP,"Controle"),paste("TG.Lfc",lfc,".",colnames(CellDiffGenTable)[j],".csv", sep = "")),row.names=FALSE, quote = FALSE)
    
    celllfc <- celllfc[celllfc$pvalue < pval , ,drop=FALSE]
    genes_Not_found <- celllfc[(!(rownames(celllfc) %in% CellnetTable[,1,])),,drop=FALSE]
    
    if (nrow(celllfc) <= 5000){
      CellnetExt2 <- merge(CellnetTable,celllfc,by.x="TG", by.y="row.names")
    } else {
      CellnetExt2 <- merge(CellnetTable,celllfc[1:5000,,drop=FALSE],by.x="TG", by.y="row.names")
      i <- 5000
      while(i < nrow(celllfc)){
        k <- i+1
        i <- i+5000
        if (i > nrow(celllfc)){
          i <- nrow(celllfc)
        }
        CellnetExtTemps <- merge(CellnetTable,celllfc[k:i,,drop=FALSE],by.x="TG", by.y="row.names")
        CellnetExt2 <- rbind(CellnetExt2,CellnetExtTemps)
      }
    }
    CellnetExt <- CellnetExt2[,-7]
    colnames(CellnetExt2)[c(7)] <- c("log2FoldChange")
    #if (exists("cellup")){
    #  namesresult <- rownames(cellup)
    #  cellup <- rbind(cellup,as.matrix(sum(celllfc[,1,drop=FALSE] > lfc)))
    #  celldown <- rbind(celldown,as.matrix(sum(celllfc[,1,drop=FALSE] < -lfc)))
    #  rownames(cellup) <- c(namesresult,colnames(CellDiffGenTable)[j])
    #  rownames(celldown) <- c(namesresult,colnames(CellDiffGenTable)[j])
    #  geneselect <- rbind(geneselect,as.matrix(rownames(celllfc)))
    #  cellbool <- merge(cellbool,celllfc[,1,drop=FALSE],all=TRUE,by="row.names")
    #  rownames(cellbool) <- cellbool[,1]
    #  cellbool <- cellbool[,-1,drop=FALSE]
    #  namesNotFound <- rownames(ResumGeneNotFound)
    #  ResumGeneNotFound <- rbind(ResumGeneNotFound,matrix(c(nrow(genes_Not_found),nrow(celllfc),(nrow(genes_Not_found)/nrow(celllfc))*100),nrow=1))
    #  rownames(ResumGeneNotFound) <- c(namesNotFound,colnames(CellDiffGenTable)[j])
    #} else{
      cellup <- as.matrix(sum(celllfc[,1,drop=FALSE] > lfc))
      celldown <- as.matrix(sum(celllfc[,1,drop=FALSE] < -lfc))
      rownames(cellup) <- c(colnames(CellDiffGenTable)[j])
      rownames(celldown) <- c(colnames(CellDiffGenTable)[j])
      geneselect <- as.matrix(rownames(celllfc))
      cellbool <- celllfc[,1,drop=FALSE]
      ResumGeneNotFound <- matrix(c(nrow(genes_Not_found),nrow(celllfc),(nrow(genes_Not_found)/nrow(celllfc))*100),nrow=1)
      rownames(ResumGeneNotFound) <- c(colnames(CellDiffGenTable)[j])
    #}
    # write.csv(CellnetExt, file = file.path(file.path(outdirXP,"Network"),paste("CellnetExt.Lfc",lfc,".",colnames(CellDiffGenTable)[j],".csv", sep = "")), row.names=FALSE, quote = FALSE)
    # write.csv(CellnetExt2, file = file.path(file.path(outdirXP,"Network"),paste("CellnetExtEnrch.Lfc",lfc,".",colnames(CellDiffGenTable)[j],".csv", sep = "")), row.names=FALSE, quote = FALSE)
    write.table(celllfc[,1,drop=FALSE], file = file.path(file.path(outdirXP,"Tetrafiles"),paste("TG.Lfc",lfc,".",colnames(CellDiffGenTable)[j],".tsv", sep = "")), quote = FALSE, sep='\t',col.names=NA)
    # write.table(genes_Not_found, file = file.path(file.path(outdirXP,"Genes_not_found"),paste("Gene_Not_Found.",colnames(CellDiffGenTable)[j],".tsv", sep = "")), quote = FALSE, sep='\t',col.names=NA)
    
    #j <- j+1
    list(cellup,celldown,geneselect,cellbool,ResumGeneNotFound)
  }
  stopCluster(cl)
  
  
  cellup <- results[[1]][[1]]
  celldown <- results[[1]][[2]]
  geneselect <- results[[1]][[3]]
  listcellbool <- list(results[[1]][[4]])
  ResumGeneNotFound <- results[[1]][[5]]
  
  j <- 2
  while(j <= ncol(CellDiffGenTable)){
    cellresults <- results[[j]]
    
    #namesresult <- rownames(cellup)
    cellup <- rbind(cellup,cellresults[[1]])
    celldown <- rbind(celldown,cellresults[[2]])
    
    # rownames(cellup) <- c(namesresult,colnames(CellDiffGenTable)[j])
    # rownames(celldown) <- c(namesresult,colnames(CellDiffGenTable)[j])
    
    geneselect <- rbind(geneselect,cellresults[[3]])
    listcellbool[[j]] <- cellresults[[4]]
    
    #namesNotFound <- rownames(ResumGeneNotFound)
    ResumGeneNotFound <- rbind(ResumGeneNotFound,cellresults[[5]])
    #rownames(ResumGeneNotFound) <- c(namesNotFound,colnames(CellDiffGenTable)[j])
    
    j <- j+1
  }
  
  cl <- makeCluster(Core)
  registerDoParallel(cl)
  while (length(listcellbool) > 1){
    nbjob <- as.integer(length(listcellbool)/2)
    results <- foreach(j = 1:nbjob) %dopar% {
      cellbool <- merge(listcellbool[[j*2-1]],listcellbool[[j*2]],all=TRUE,by="row.names")
      rownames(cellbool) <- cellbool[,1]
      cellbool <- cellbool[,-1,drop=FALSE]
      cellbool
    }
    if (length(listcellbool)%%2 > 0){
      listcellbool <- c(results,list(listcellbool[[nbjob*2+1]]))
    } else {
      listcellbool <- results
    }
  }
  stopCluster(cl)
  
  cellbool <- as.matrix(listcellbool[[1]])
  
  cellbool[is.infinite(cellbool)] = 0
  cellbool[is.na(cellbool)] = 0
  cellbool[cellbool < -lfc] = -1
  cellbool[cellbool > lfc] = 1
  cellbool[cellbool > -lfc & cellbool < lfc] = 0
  write.csv(cellbool, file = file.path(outdirXP,"cell.GeneDiffExpBool.csv"), quote = FALSE)
  write.table(cellbool, file = file.path(outdirXP,"cell.GeneDiffExpBool.tsv"), quote = FALSE, sep='\t',col.names=NA)
  
  colnames(ResumGeneNotFound) <- c("not_found","Total","Pourcentage Not Found")
  write.table(ResumGeneNotFound, file = file.path(outdirXP,"resum_geneNotFound.tsv"), quote = FALSE, sep='\t',col.names=NA)
  png(file.path(outdirXP,"GNF.scatterplot.png"), 1200, 1000, pointsize=20)
  plot(log2(ResumGeneNotFound[,2]),ResumGeneNotFound[,3], main="Scatterplot about the pourcentage of genes not found in network file related by the number of genes ",xlab="log2(Number total genes query)", ylab="Pourcentage Gene Not found", pch=19)
  dev.off()
  
  celltotal <- cellup + celldown
  diffExp(TableLfcPval,celltotal,cellup,celldown,lfc,pval,outdirXP)
  
  geneselect <- geneselect[!duplicated(geneselect[,1]),,drop=FALSE]
  colnames(geneselect)[1] <- c("genes")
  cellResum <- merge(geneselect,CellDiffGenTable,by.x="genes", by.y="row.names")
  rownames(cellResum) <- cellResum[,1]
  cellResum <- cellResum[,-1,drop=FALSE]
  write.csv(cellResum, file = file.path(outdirXP,"cell.GeneDiffExp.csv"), quote = FALSE)
}

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################

#################################################################################################################################
###################################### Functions creates a rapid overview of the data ###########################################
#################################################################################################################################

gene.range <- function(geneID,norm.fold.change.genes,outdir) {
  png(file.path(outdir,paste(geneID,"lfc.boxplot.png", sep = "")), 1200, 1000, pointsize=20)
  gene <- norm.fold.change.genes[rownames(norm.fold.change.genes)==geneID,]
  range <- apply(gene[,2:length(gene)],1,range)
  max <- apply(gene[,2:length(gene)],1,max)
  min <- apply(gene[,2:length(gene)],1,min)
  boxplot(norm.fold.change.genes[,1])
  abline(h=1, col="green")
  abline(h=-1, col="green")
  abline(h=0, col="gray")
  if(any(rownames(norm.fold.change.genes)==geneID)){
    bulk <- norm.fold.change.genes[rownames(norm.fold.change.genes)==geneID,1]
    if(!is.infinite(bulk)){
      points(1,bulk, col="blue",lwd=5)
    }
    if(!is.infinite(min)){
      points(1,min, col="green",lwd=5)
    }
    if(!is.infinite(max)){
      points(1,max, col="red",lwd=5)
    }
  }
  dev.off()
}

diffExp <- function(bulk,celltotal,cellup,celldown,lfc,pval,outdirXP){
  
  bulkup <- as.matrix(sum(bulk[,1,drop=FALSE] > lfc & bulk[,2,drop=FALSE] < pval))
  bulkdown <- as.matrix(sum(bulk[,1,drop=FALSE] < -lfc & bulk[,2,drop=FALSE] < pval))
  bulktotal <- bulkup + bulkdown
  
  #mcellresult <- as.matrix(cellresult)
  #mcellresult[!is.finite(mcellresult)] = 0
  
  png(file.path(outdirXP,"DifferentialExpressionRepartition.png"), 1200, 1000, pointsize=20)
  plot(cellup[,1],celldown[,1], main="Scatterplot Cell Differential Expression",xlab="UP ", ylab="Down", pch=19)
  dev.off()
  
  png(file.path(outdirXP,"HistogramDifferentialExpressionRepartition.png"), 1200, 1000, pointsize=20)
  breaknumber <- as.integer(max(celltotal[,1])/50)
  if(breaknumber < 20 ){
    breaknumber <- 20
  }
  hist(celltotal[order(celltotal[,1],decreasing=TRUE),],main="Histogram repartition cells number differential genes expression",xlab="Number Gene differential expressed",ylab="Number cell",border="blue",col="red",breaks=breaknumber)
  dev.off()
  
  png(file.path(outdirXP,"DifferentialExpressionGeneRepartition.png"), 1200, 1000, pointsize=20)
  barplot(celltotal[order(celltotal[,1],decreasing=TRUE),],main="Differential genes expressed per cell",xlab="Cells",ylab="Number of genes differential expressed per cell")
  dev.off()
  
  up <- rbind(bulkup,cellup)
  down <- rbind(bulkdown,celldown)
  total <- rbind(bulktotal,celltotal)
  cellDiff <- cbind(up,down,total)
  colnames(cellDiff) <- c("up","down","total")
  rownames(cellDiff)[1] <- c("Bulk")
  
  write.csv(cellDiff, file = file.path(outdirXP,"cell.ResumGeneDiffExp.csv"))

}

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################

#################################################################################################################################
######################################### Normalisation Function ################################################################
#################################################################################################################################

# Function from https://davetang.org/muse/2014/07/07/quantile-normalisation-in-r/
quantile_normalisation <- function(df, outdir){
  df_rank <- apply(df,2,rank,ties.method="min")
  df_sorted <- data.frame(apply(df, 2, sort))
  df_mean <- apply(df_sorted, 1, mean)
  
  index_to_mean <- function(my_index, my_mean){
    return(my_mean[my_index])
  }
  
  df_final <- apply(df_rank, 2, index_to_mean, my_mean=df_mean)
  rownames(df_final) <- rownames(df)
  # MAPlot(df, df_final, outdir)
  return(df_final)
}

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################

AnnalData <- function(se, normcounts, outdir, lfc, pval, useAlpha, alpha, fit="basic"){
  
  library(DESeq2)
  dds <- DESeqDataSet(se, design = ~ group)
  matrixNorm <- as.matrix(((counts(dds, normalized=FALSE))/(normcounts)))
  matrixNorm[ is.na(matrixNorm)] = 0.00000000000001
  matrixNorm[ matrixNorm <= 0 ] = 1
  normalizationFactors(dds) <- matrixNorm
  ####### Counts at 0 to other number. ##########
  if (any(counts(dds, normalized=TRUE) != normcounts)){
    Rawcounts <- assay(se)
    Rawcounts[counts(dds, normalized=TRUE) != normcounts & Rawcounts == 0] = 1
    assay(se) <- Rawcounts
    dds <- DESeqDataSet(se, design = ~ group)
    matrixNorm <- as.matrix(((counts(dds, normalized=FALSE))/(normcounts)))
    matrixNorm[ is.na(matrixNorm)] = 0.00000000000001
    normalizationFactors(dds) <- matrixNorm
  }
  normcounts <- counts(dds, normalized=TRUE)
  
  if (fit == "basic"){
    ddss <- DESeq(dds,quiet = TRUE)
  } else {
    ddss <- DESeq(dds,fitType = c(fit),quiet = TRUE)
  }
  
  dds <- dds[ rowSums(counts(dds)) > 0, ]
  
  if (fit == "basic"){
    dds <- DESeq(dds, quiet = TRUE)
  } else {
    dds <- DESeq(dds,fitType = c(fit), quiet = TRUE)
  }
  
  scatterplot(counts(dds, normalized=FALSE), counts(dds, normalized=TRUE), outdir)
  MAPlot(counts(dds, normalized=FALSE), counts(dds, normalized=TRUE), outdir)
  
  res <- results(dds)
  
  MAPlotG(res, outdir)
  volcanoplot1(res, lfc, pvalue, useAlpha, alpha, outdir)
  volcanoplot2(res, lfc, pvalue, useAlpha, alpha, outdir)
  
  res.DESeq2 <- res
  
  if ( useAlpha ){
    gn.selected <- (abs(res.DESeq2$log2FoldChange) > lfc & !is.na(res.DESeq2$padj) & res.DESeq2$padj < alpha & res.DESeq2$pvalue < pval)
  } else {
    gn.selected <- (abs(res.DESeq2$log2FoldChange) > lfc & res.DESeq2$pvalue < pval)
  }
  datares <- as.data.frame(res.DESeq2)[gn.selected,]
  datacount <- as.data.frame((counts(dds, normalized=FALSE)))[gn.selected,]
  datanorm <- as.data.frame((counts(dds, normalized=TRUE)))[gn.selected,]
  if (any(gn.selected)){
    data <- data.frame(datacount,datanorm,datares)
    i <- 1
    exp <- vector("character")
    while (i <= nrow(data)){
      if (as.numeric(data[i,]$log2FoldChange) > 0){
        exp <- c(exp, "up")
      } else if (as.numeric(data[i,]$log2FoldChange) < 0) {
        exp <- c(exp, "down")
      } else {
        exp <- c(exp, "-")
      }
      i <- i+1
    }
    data <- data.frame(data,exp)
  }
  
  write.csv(counts(dds, normalized=FALSE), file = file.path(outdir,"RawCount.csv"))
  write.csv(counts(dds, normalized=TRUE), file = file.path(outdir,"NormCount.csv"))
  differential <- data.frame(counts(dds, normalized=FALSE),counts(dds, normalized=TRUE),as.data.frame(res)[,c(1:ncol(as.data.frame(res)))])
  write.csv(differential, file = file.path(outdir,"Deseq.csv"))
  write.csv(data, file = file.path(outdir,paste("Lfc.",lfc,".pvalue.",pval,".DifferentialGenes.csv", sep = "")))
  resOrderedDF <- as.data.frame(res[order(res$pvalue),])
  write.csv(resOrderedDF, file = file.path(outdir,"ResultOrder.csv"))
  
  png(file.path(outdir,"norm.effect.png"), 1200, 1000, pointsize=20)
  boxplot(data.frame(log2(counts(dds, normalized=FALSE)),log2(counts(dds, normalized=TRUE))))
  dev.off()
  
  ress <- results(ddss)
  differentials <- data.frame(counts(ddss, normalized=FALSE),counts(ddss, normalized=TRUE),as.data.frame(ress)[,c(1:ncol(as.data.frame(ress)))])
  write.csv(differentials, file = file.path(outdir,"Deseqs.csv"))
  
  return(normcounts)
}

AnnalCell <- function(se, normcounts){
  library(DESeq2)
  dds <- DESeqDataSet(se, design = ~ group)
  matrixNorm <- as.matrix(((counts(dds, normalized=FALSE))/(normcounts)))
  matrixNorm[ is.na(matrixNorm)] = 0.00000000000001
  matrixNorm[ matrixNorm <= 0 ] = 1
  normalizationFactors(dds) <- matrixNorm
  ####### Counts at 0 to other number. ##########
  if (any(counts(dds, normalized=TRUE) != normcounts)){
    Rawcounts <- assay(se)
    Rawcounts[counts(dds, normalized=TRUE) != normcounts & Rawcounts == 0] = 1
    assay(se) <- Rawcounts
    dds <- DESeqDataSet(se, design = ~ group)
    matrixNorm <- as.matrix(((counts(dds, normalized=FALSE))/(normcounts)))
    matrixNorm[ is.na(matrixNorm)] = 0.00000000000001
    normalizationFactors(dds) <- matrixNorm
  }
  normcounts <- counts(dds, normalized=TRUE)
  dds <- DESeq(dds,fitType ="local",quiet = TRUE)
  res <- results(dds)
  return(res)
}

cellcounts <- function(ratioCount, normcounts, dataCountsSCcount, dataCountsReferences, outdir){
  dir.create(outdir, showWarnings = FALSE)
  dir.create(file.path(outdir,"scatterplot"), showWarnings = FALSE)
  dir.create(file.path(outdir,"MA.Plot"), showWarnings = FALSE)
  SCcountsNorm <- ratioCount*normcounts[,2]
  NormmatEnv <- cbind(normcounts[,1, drop=FALSE],SCcountsNorm)
  RawmatEnv <- cbind(dataCountsReferences,dataCountsSCcount)
  
  png(file.path(outdir,"boxplot.png"), 1200, 1000, pointsize=20)
  boxplot(data.frame(log2(normcounts),log2(SCcountsNorm[,1:10])))
  dev.off()
  
  #scatterplot(RawmatEnv, NormmatEnv, file.path(outdir,"scatterplot"))
  #MAPlot(RawmatEnv, NormmatEnv, file.path(outdir,"MA.Plot"))
  write.csv(SCcountsNorm, file = file.path(outdir,"NormCount.csv"))
  
  #coldataref <- GenerColdata(RawmatEnv[,1, drop=FALSE],"ref")
  #coldataSC <- GenerColdata(RawmatEnv[,2, drop=FALSE],"SC")
  #coldataXP <- rbind(coldataref,coldataSC)
  #seXP <- SummarizedExperiment(assay=as.matrix(RawmatEnv[,c(1,2)]), rowData=rownames(RawmatEnv[,c(1,2)]), colData=coldataXP)
  #seXP <- as(seXP,"RangedSummarizedExperiment")
  #res <- AnnalCell(seXP, NormmatEnv[,c(1,2)])
  #cellresult <- data.frame(res$log2FoldChange)
  #i <- 3
  #while (i <= ncol(NormmatEnv)){
  #  coldataref <- GenerColdata(RawmatEnv[,1, drop=FALSE],"ref")
  #  coldataSC <- GenerColdata(RawmatEnv[,i, drop=FALSE],"SC")
  #  coldataXP <- rbind(coldataref,coldataSC)
  #  seXP <- SummarizedExperiment(assay=as.matrix(RawmatEnv[,c(1,i)]), rowData=rownames(RawmatEnv[,c(1,i)]), colData=coldataXP)
  #  seXP <- as(seXP,"RangedSummarizedExperiment")
  #  res <- AnnalCell(seXP, NormmatEnv[,c(1,i)])
  #  cellresult <- cbind(cellresult,res$log2FoldChange)
  #  i <- i+1
  #}
  #rownames(cellresult) <- rownames(dataCountsSCcount)
  #colnames(cellresult) <- colnames(dataCountsSCcount)
  
  cellresult2 <- log2((NormmatEnv[,2:ncol(NormmatEnv)]+0.01)/(NormmatEnv[,1]+0.01)) # Big modification of lfc for the counts !!!!!! Remove infinite and allow access a number of genes.
  rownames(cellresult2) <- rownames(dataCountsSCcount)
  colnames(cellresult2) <- colnames(dataCountsSCcount)
  
  #write.csv(cellresult, file = file.path(outdir,"Cell.lfc.csv"))
  write.csv(cellresult2, file = file.path(outdir,"Cell2.lfc.csv"))
  return(cellresult2)
}

normalisationMean <- function(dataCountsReferences,dataSumSCcount,dataCountsSCcount,ratioCount,outdirXP,Core){
  library(SummarizedExperiment)
  dataCountsXP <- cbind(dataCountsReferences,dataSumSCcount)
  coldataref <- GenerColdata(dataCountsReferences,"ref")
  coldataSC <- GenerColdata(dataSumSCcount,"SC")
  coldataXP <- rbind(coldataref,coldataSC)

  seXP <- SummarizedExperiment(assay=as.matrix(dataCountsXP), rowData=rownames(dataCountsXP), colData=coldataXP)
  seXP <- as(seXP,"RangedSummarizedExperiment")
  ############## Another quantile normalisation ########################
  ###### Effet moyenne vs sum
  dataMoySCcount <- dataSumSCcount/ncol(ratioCount)
  dataCountsReferences <- dataCountsReferences-ncol(ratioCount)+1
  ### Remove count number
  dataCountsXP <- cbind(dataCountsReferences,dataMoySCcount)
  coldataref <- GenerColdata(dataCountsReferences,"ref")
  coldataSC <- GenerColdata(dataMoySCcount,"SC")
  coldataXP <- rbind(coldataref,coldataSC)
  
  dataCountNorm <- quantile_normalisation(dataCountsXP,outdirXP)
  png(file.path(outdirXP,"normQ.effect.png"), 1200, 1000, pointsize=20)
  boxplot(data.frame(log2(dataCountsXP),log2(dataCountNorm)))
  dev.off()
  write.csv(dataCountsXP, file = file.path(outdirXP,"QRawCount.csv"))
  write.csv(dataCountNorm, file = file.path(outdirXP,"QNormCount.csv"))
  dir.create(file.path(outdirXP,"verif"), showWarnings = FALSE)
  scatterplot(dataCountsXP, dataCountNorm, file.path(outdirXP,"verif"))
  MAPlot(dataCountsXP, dataCountNorm, file.path(outdirXP,"verif"))
  
  normcounts <- AnnalData(seXP, dataCountNorm, outdirXP, lfc, pval, useAlpha, alpha)
  cellresult <- cellcounts(ratioCount, normcounts, dataCountsSCcount, dataCountsReferences, file.path(outdirXP,"SingleCell"))
  
  tot <- read.csv(file.path(outdirXP,"Deseqs.csv"),row.names = 1 , header = TRUE)
  write.csv(cbind(dataCountsXP,tot[,c(3:4,6,9)],cellresult), file = file.path(outdirXP,"Cells.results.csv"))
  
  png(file.path(outdirXP,"lfc.boxplot.png"), 1200, 1000, pointsize=20)
  boxplot(data.frame(tot[,c(6)],cellresult[,1:100]))
  abline(h=1, col="red")
  abline(h=-1, col="red")
  abline(h=0, col="gray")
  dev.off()
  
  gene.range("NANOG",data.frame(tot[,c(6),drop=FALSE],cellresult),outdirXP)
  gene.range("FOXG1",data.frame(tot[,c(6),drop=FALSE],cellresult),outdirXP)
  
  CellnetExtract(file.path(outdirXP,"Deseq.csv"), CellnetFile, outdirXP, lfc, pval)
  cellcounts <- read.csv(file.path(file.path(outdirXP,"SingleCell"),"NormCount.csv"),row.names = 1 , header = TRUE)
  CellnetCellExtract(cellresult, CellnetFile, file.path(outdirXP,"SingleCell"), lfc, tot[,c(6,9)], pval, cbind(tot[,3,drop=FALSE],cellcounts),Core)
}

normalisationSum <- function(dataCountsReferences,dataSumSCcount,dataCountsSCcount,ratioCount,outdirXP,Core){
  library(SummarizedExperiment)
  dataCountsXP <- cbind(dataCountsReferences,dataSumSCcount)
  coldataref <- GenerColdata(dataCountsReferences,"ref")
  coldataSC <- GenerColdata(dataSumSCcount,"SC")
  coldataXP <- rbind(coldataref,coldataSC)

  seXP <- SummarizedExperiment(assay=as.matrix(dataCountsXP), rowData=rownames(dataCountsXP), colData=coldataXP)
  seXP <- as(seXP,"RangedSummarizedExperiment")
  
  dataCountNorm <- quantile_normalisation(dataCountsXP,outdirXP)
  png(file.path(outdirXP,"normQ.effect.png"), 1200, 1000, pointsize=20)
  boxplot(data.frame(log2(dataCountsXP),log2(dataCountNorm)))
  dev.off()
  write.csv(dataCountsXP, file = file.path(outdirXP,"QRawCount.csv"))
  write.csv(dataCountNorm, file = file.path(outdirXP,"QNormCount.csv"))
  dir.create(file.path(outdirXP,"verif"), showWarnings = FALSE)
  scatterplot(dataCountsXP, dataCountNorm, file.path(outdirXP,"verif"))
  MAPlot(dataCountsXP, dataCountNorm, file.path(outdirXP,"verif"))
  
  normcounts <- AnnalData(seXP, dataCountNorm, outdirXP, lfc, pval, useAlpha, alpha)
  cellresult <- cellcounts(ratioCount, normcounts, dataCountsSCcount, dataCountsReferences, file.path(outdirXP,"SingleCell"))
  
  tot <- read.csv(file.path(outdirXP,"Deseqs.csv"),row.names = 1 , header = TRUE)
  write.csv(cbind(dataCountsXP,tot[,c(3:4,6,9)],cellresult), file = file.path(outdirXP,"Cells.results.csv"))
  
  png(file.path(outdirXP,"lfc.boxplot.png"), 1200, 1000, pointsize=20)
  boxplot(data.frame(tot[,c(6)],cellresult[,1:100]))
  abline(h=1, col="red")
  abline(h=-1, col="red")
  abline(h=0, col="gray")
  dev.off()
  
  gene.range("NANOG",data.frame(tot[,c(6),drop=FALSE],cellresult),outdirXP)
  gene.range("FOXG1",data.frame(tot[,c(6),drop=FALSE],cellresult),outdirXP)
  
  CellnetExtract(file.path(outdirXP,"Deseq.csv"), CellnetFile, outdirXP, lfc, pval)
  cellcounts <- read.csv(file.path(file.path(outdirXP,"SingleCell"),"NormCount.csv"),row.names = 1 , header = TRUE)
  CellnetCellExtract(cellresult, CellnetFile, file.path(outdirXP,"SingleCell"), lfc, tot[,c(6,9)], pval, cbind(tot[,3,drop=FALSE],cellcounts),Core)
}

normalisation <- function(dataCountsReferences,dataSumSCcount,dataCountsSCcount,ratioCount,outdirXP,method,Core){
  if(method == "Mean"){
    normalisationMean(dataCountsReferences,dataSumSCcount,dataCountsSCcount,ratioCount,outdirXP,Core)
  }
  else if (method == "Sums"){
    normalisationSum(dataCountsReferences,dataSumSCcount,dataCountsSCcount,ratioCount,outdirXP,Core)
  }
}

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################

#### Reference SCFile
param <- read.csv(csvparam, header = TRUE)

references <- read.csv(file.path(refdir,paste(param$Reference[1],".csv", sep = "")),row.names = 1 , header = TRUE)
SC <- read.csv(file.path(SCdir,paste(param$SCFile[1],".csv", sep = "")),row.names = 1 , header = TRUE)

outdirNorm <- file.path(outdir,paste("Ref.",param$Reference[1],"_SC.",param$SCFile[1],"_lfc.",lfc,"_pval.",pval,"_Norm.",method, sep = ""))
dir.create(outdirNorm, showWarnings = FALSE)

dataCountsReferences <- runImport(references,countdir,"ref")
if (ncol(dataCountsReferences) > 1) {
  dataCountsReferences <- quantile_normalisation(dataCountsReferences,outdirNorm)
}
dataCountsReferences <- as.matrix(rowSums(dataCountsReferences)/ncol(dataCountsReferences))
namerow <- rownames(dataCountsReferences)
dataCountsReferences <- as.matrix(as.integer(dataCountsReferences[,1]))
colnames(dataCountsReferences) <- c(paste("ref.",param$Reference[1]))
rownames(dataCountsReferences) <- namerow

dataCountsSCcount <- runImport(SC,countdir,"SC")
colnames(dataCountsSCcount) <- GenerCellName(colnames(dataCountsSCcount),param$SCFile[1],outdirNorm)

dataCountsXP <- fusionCounts(dataCountsReferences,dataCountsSCcount)

dataCountsReferences <- dataCountsXP[,c(1:ncol(dataCountsReferences)),drop=FALSE]
dataCountsSCcount <- dataCountsXP[,c((ncol(dataCountsReferences)+1):ncol(dataCountsXP)),drop=FALSE]

###############################################
########## Suppression Gene 0 Expression ######
dataCountsXP <- dataCountsXP[ rowSums(dataCountsXP) > 0, ]
dataCountsReferences <- dataCountsXP[,c(1:ncol(dataCountsReferences)),drop=FALSE]
dataCountsSCcount <- dataCountsXP[,c((ncol(dataCountsReferences)+1):ncol(dataCountsXP)),drop=FALSE]

###############################################
########## Suppression Gene 0 Expression SC ###
dataCountsSCcount <- dataCountsSCcount[ rowSums(dataCountsSCcount) > 0, ]

#### Add +1 ######
dataCountsSCcount <- dataCountsSCcount+1
dataCountsReferences <- dataCountsReferences+ncol(dataCountsSCcount)

dataCountsXP <- fusionCounts(dataCountsReferences,dataCountsSCcount)
dataCountsReferences <- dataCountsXP[,c(1:ncol(dataCountsReferences)),drop=FALSE]
dataCountsSCcount <- dataCountsXP[,c((ncol(dataCountsReferences)+1):ncol(dataCountsXP)),drop=FALSE]
dataSumSCcount <- as.matrix(rowSums(dataCountsSCcount))
colnames(dataSumSCcount) <- c(paste("SC.",param$SCFile[1],sep = ""))
ratioCount <- (dataCountsSCcount)/((dataSumSCcount[,1]/ncol(dataCountsSCcount)))
ratioCount[ is.na(ratioCount)] = 0
colnames(ratioCount) <- colnames(dataCountsSCcount)
rownames(ratioCount) <- rownames(dataCountsSCcount)

normalisation(dataCountsReferences,dataSumSCcount,dataCountsSCcount,ratioCount,outdirNorm,method,Core)

