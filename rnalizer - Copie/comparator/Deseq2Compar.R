#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)<7) {
  stop("At least five argument must be supplied.\n", call.=FALSE)
}
library(SummarizedExperiment)

CellnetFile <- "/mnt/zone2/studerf/Pipeline/SCNorm/Human_Big_GRN_032014.csv"
refdir <- "/mnt/zone2/studerf"
compdir <- "/mnt/zone2/studerf"
countdir <- "/mnt/zone2/studerf/counts"
outdir <- "/mnt/zone2/studerf"
csvparam <- "/mnt/zone2/studerf/param8.csv" # Contain study param. Group are the param for comparaison. Group correspond a collumn in ComparFile or File (For compare allsample vs Reference)
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
CellnetFile <- args[6]
lfc <- as.numeric(args[7])
pval <- as.numeric(args[8])
Core <- as.numeric(args[9])

#################################################################################################################################
################################################ Functions ######################################################################
#################################################################################################################################

GRCh37IDandSymbol <- function(){
  library(biomaRt)
  #ensembl54 <- useMart(host='http://www.ensembl.org', 
  #                     biomart='ENSEMBL_MART_ENSEMBL', 
  #                     dataset='hsapiens_gene_ensembl')
  ensembl54 <- useMart(host='http://grch37.ensembl.org', 
                       biomart='ENSEMBL_MART_ENSEMBL', 
                       dataset='hsapiens_gene_ensembl')
  #ensembl54 <- useMart(host='feb2014.archive.ensembl.org', 
  #                     biomart='ENSEMBL_MART_ENSEMBL', 
  #                     dataset='hsapiens_gene_ensembl')
  attributes=c('ensembl_gene_id','hgnc_symbol')
  G_list<- getBM(attributes=attributes, values="*",
                 mart=ensembl54, uniqueRows=T)
  return(G_list)
}

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

fusionCounts <- function(dataCounts,dataCounts2){
  rownames(dataCounts) <- toupper(rownames(dataCounts))
  rownames(dataCounts2) <- toupper(rownames(dataCounts2))
  newDFCount <- merge(dataCounts,dataCounts2,by="row.names")
  namerow <- newDFCount[,1]
  newDFCount <- newDFCount[,-1]
  rownames(newDFCount) <- namerow
  return(newDFCount)
}

runImport <- function(DFimport,countdir,sampleType){
  IDlist <- GRCh37IDandSymbol()
  dataCounts <- read.csv(file.path(countdir,paste(DFimport$Run[1],".csv", sep = "")),row.names = 1 , header = TRUE)
  if (all(grepl("ENSG*",rownames(dataCounts),perl=TRUE))){
    dataCounts <- ConvertEnsemblIDtoSymbol(dataCounts,IDlist)
  }
  colnames(dataCounts) <- c(paste0(sampleType,".1.",rownames(DFimport)[1]))
  i <- 2
  while (i <= nrow(DFimport)){
    dataCounts2 <- read.csv(file.path(countdir,paste(DFimport$Run[i],".csv", sep = "")),row.names = 1 , header = TRUE)
    if (all(grepl("ENSG*",rownames(dataCounts2),perl=TRUE))){
      dataCounts2 <- ConvertEnsemblIDtoSymbol(dataCounts2,IDlist)
    }
    colnames(dataCounts2) <- c(paste0(sampleType,".",i,".",rownames(DFimport)[i]))
    dataCounts <- fusionCounts(dataCounts,dataCounts2)
    i <- i+1
  }
  return(dataCounts)
}

GenerColdata <- function(dataCounts,grp){
  group <- rep(grp,ncol(dataCounts))
  coldata <- data.frame(group)
  rownames(coldata) <- colnames(dataCounts)
  return(coldata)
}

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

#################################################################################################################################
########################################### Graphic Function for Normalisation ##################################################
#################################################################################################################################

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
      coord_fixed() + facet_grid( . ~ transformation) + geom_smooth(method='gam', size = 1.25, color = "yellow") + geom_smooth(method='gam', size = 0.5, color = "red") + geom_smooth(span = 0.01, color = "green", size = 0.25) + labs(x = colnames(normcount)[1]) + labs(y = colnames(normcount)[i])
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
################################## Function Graphic for Deseq 2 Annalyse ########################################################
#################################################################################################################################

volcanoplot2 <- function(res, lfc, pvalue, useAlpha, alpha, outdir){
  res.DESeq2 <- res
  png(file.path(outdir,"diffexpr-volcanoplot2.png"), 1200, 1000, pointsize=20)
  tab = data.frame(logFC = res$log2FoldChange, negLogPval = -log10(res$pvalue))
  par(mar = c(5, 4, 4, 4))
  plot(tab, pch = 16, cex = 0.6, xlab = expression(log[2]~fold~change), ylab = expression(-log[10]~pvalue))
  if (useAlpha){
    signGenes = (abs(res.DESeq2$log2FoldChange) > lfc & !is.na(res.DESeq2$padj) & res.DESeq2$padj < alpha & res.DESeq2$pvalue < pval)
  } else{
    signGenes = (abs(res.DESeq2$log2FoldChange) > lfc & res.DESeq2$pvalue < pval)
  }
  #signGenes = (abs(tab$logFC) > lfc & tab$negLogPval > -log10(pval))
  points(tab[signGenes, ], pch = 16, cex = 0.8, col = "red") 
  abline(h = -log10(pval), col = "green3", lty = 2, lwd=3) 
  abline(v = c(-lfc, lfc), col = "blue", lty = 2, lwd=3) 
  mtext(paste("pval =", pval), side = 4, at = -log10(pval), cex = 0.8, line = 0.5, las = 1) 
  mtext(c(paste("-", lfc, "fold"), paste("+", lfc, "fold")), side = 3, at = c(-lfc, lfc), cex = 0.8, line = 0.5)
  dev.off()
}

volcanoplot1 <- function(res, lfc, pvalue, useAlpha, alpha, outdir){
  png(file.path(outdir,"diffexpr-volcanoplot.png"), 1200, 1000, pointsize=20)
  res.DESeq2 <- res
  cols <- densCols(res.DESeq2$log2FoldChange, -log10(res.DESeq2$pvalue))
  plot(res.DESeq2$log2FoldChange, -log10(res.DESeq2$padj), col=cols, panel.first=grid(),
       main="Volcano plot", xlab="Effect size: log2(fold-change)", ylab="-log10(adjusted p-value)",
       pch=20, cex=0.6)
  abline(v=0)
  abline(v=c(-lfc, lfc), col="brown", lwd=3)
  mtext(paste("padj =", alpha), side = 4)
  abline(h=-log10(alpha), col="brown", lwd=3)
  if (useAlpha){
    signGenes = (abs(res.DESeq2$log2FoldChange) > lfc & !is.na(res.DESeq2$padj) & res.DESeq2$padj < alpha & res.DESeq2$pvalue < pval)
  } else{
    signGenes = (abs(res.DESeq2$log2FoldChange) > lfc & res.DESeq2$pvalue < pval)
  }
  valu = data.frame(res.DESeq2$log2FoldChange,-log10(res.DESeq2$padj))
  points(valu[signGenes, ], pch = 20, cex = 0.6, col = "red")
  #gn.selected <- abs(res.DESeq2$log2FoldChange) > 1 & res.DESeq2$padj < alpha 
  #text(res.DESeq2$log2FoldChange[gn.selected],
  #     -log10(res.DESeq2$padj)[gn.selected],
  #     lab=rownames(res.DESeq2)[gn.selected ], cex=0.4)
  dev.off()
}

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
######################################### Normalisation Function ################################################################
#################################################################################################################################

# Function from https://davetang.org/muse/2014/07/07/quantile-normalisation-in-r/
quantile_normalisation <- function(df){
  df_rank <- apply(df,2,rank,ties.method="min")
  df_sorted <- data.frame(apply(df, 2, sort))
  df_mean <- apply(df_sorted, 1, mean)
  
  index_to_mean <- function(my_index, my_mean){
    return(my_mean[my_index])
  }
  
  df_final <- apply(df_rank, 2, index_to_mean, my_mean=df_mean)
  rownames(df_final) <- rownames(df)

  return(df_final)
}

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

annalyses <- function(dataCountsXP, coldataXP,outdirXP, lfc, pval, useAlpha, alpha, CellnetFile){
  dataCountsXP <- dataCountsXP+1
  ############## Another quantile normalisation ########################
  dataCountNorm <- quantile_normalisation(dataCountsXP)
  
  png(file.path(outdirXP,"raw.effect.png"), 1200, 1000, pointsize=20)
  boxplot(data.frame(dataCountsXP), las=2, outline = FALSE)
  dev.off()
  
  png(file.path(outdirXP,"norm.effect.png"), 1200, 1000, pointsize=20)
  boxplot(data.frame(dataCountNorm), las=2, outline = FALSE)
  dev.off()
  
  i <- 1
  group <- coldataXP[i,1]
  RawCountRef <- dataCountsXP[,i,drop=FALSE]
  NormCountRef <- dataCountNorm[,i,drop=FALSE]
  ColdataRef <- coldataXP[i,,drop=FALSE]
  i <- i+1
  while (i <= nrow(coldataXP) && group == coldataXP[i,1] ){
    RawCountRef <- cbind(RawCountRef,dataCountsXP[,i,drop=FALSE])
    NormCountRef <- cbind(NormCountRef,dataCountNorm[,i,drop=FALSE])
    ColdataRef <- rbind(ColdataRef,coldataXP[i,,drop=FALSE])
    i <- i+1
  }
  
  while (i <= nrow(coldataXP)){
    group <- coldataXP[i,1]
    RawCountComp <- dataCountsXP[,i,drop=FALSE]
    NormCountComp <- dataCountNorm[,i,drop=FALSE]
    ColdataComp <- coldataXP[i,,drop=FALSE]
    i <- i+1
    while (i <= nrow(coldataXP) && group == coldataXP[i,1] ){
      RawCountComp <- cbind(RawCountComp,dataCountsXP[,i,drop=FALSE])
      NormCountComp <- cbind(NormCountComp,dataCountNorm[,i,drop=FALSE])
      ColdataComp <- rbind(ColdataComp,coldataXP[i,,drop=FALSE])
      i <- i+1
    }
    
    dataCountsGroup <- cbind(RawCountRef,RawCountComp)
    dataCountNormGroup <- cbind(NormCountRef,NormCountComp)
    coldataGroup <- rbind(ColdataRef,ColdataComp)
    
    outdirGroup <- file.path(outdirXP,group)
    dir.create(outdirGroup, showWarnings = FALSE)
    
    seXP <- SummarizedExperiment(assay=as.matrix(dataCountsGroup), rowData=rownames(dataCountsGroup), colData=coldataGroup)
    seXP <- as(seXP,"RangedSummarizedExperiment")
    sortie <- AnnalData(seXP, dataCountNormGroup, outdirGroup, lfc, pval, useAlpha, alpha)
    CellnetExtract(file.path(outdirGroup,"Deseq.csv"), CellnetFile, outdirGroup, lfc, pval)
  }
  
}

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################

##### Il faut rajouter le traitement des organismes Orga <- args[2]

param <- read.csv(csvparam, header = TRUE)

references <- read.csv(file.path(refdir,paste(param$ReferenceFile[1],".csv", sep = "")),row.names = 1 , header = TRUE)

compars <- read.csv(file.path(compdir,paste(param$ComparFile[1],".csv", sep = "")),row.names = 1 , header = TRUE)
compars <- compars[order(compars[,as.vector(param$Group[1])]),]

dataCountsReferences <- runImport(references,countdir,"ref")
coldataref <- GenerColdata(dataCountsReferences,"ref")

outdirComp <- file.path(outdir,paste("Ref.",param$ReferenceFile[1],"Comp.",param$ComparFile[1],"Group.",param$Group[1],".lfc.",lfc,".pval.",pval, sep = ""))
dir.create(outdirComp, showWarnings = FALSE)


i <- 1
group <- as.character(compars[i,as.vector(param$Group[1])])
comparGroup <- compars[i,]
i <- i+1
while (i <= nrow(compars) && group == as.character(compars[i,as.vector(param$Group[1])]) ){
  comparGroup <- rbind(comparGroup,compars[i,])
  i <- i+1
}
dataCountsCompar <- runImport(comparGroup,countdir,group)
coldatacomp <- GenerColdata(dataCountsCompar,group)
dataCountsXP <- fusionCounts(dataCountsReferences,dataCountsCompar)
coldataXP <- rbind(coldataref,coldatacomp)

while (i <= nrow(compars)){
  group <- as.character(compars[i,as.vector(param$Group[1])])
  comparGroup <- compars[i,]
  i <- i+1
  while (i <= nrow(compars) && group == as.character(compars[i,as.vector(param$Group[1])]) ){
    comparGroup <- rbind(comparGroup,compars[i,])
    i <- i+1
  }
  dataCountsCompar <- runImport(comparGroup,countdir,group)
  coldatacomp <- GenerColdata(dataCountsCompar,group)
  dataCountsXP <- fusionCounts(dataCountsXP,dataCountsCompar)
  coldataXP <- rbind(coldataXP,coldatacomp)
}

annalyses(dataCountsXP, coldataXP,outdirComp, lfc, pval, useAlpha, alpha,CellnetFile)
