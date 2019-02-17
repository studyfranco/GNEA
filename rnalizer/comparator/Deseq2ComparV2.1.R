#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)<7) {
  stop("At least five argument must be supplied.\n", call.=FALSE)
}
library(SummarizedExperiment)

CellnetFile <- "/mnt/zone2/studerf/Pipeline/comparator/Human_Big_GRN_032014.csv"
refdir <- "/mnt/zone2/studerf"
compdir <- "/mnt/zone2/studerf"
countdir <- "/mnt/zone2/studerf"
outdir <- "/mnt/zone2/studerf"
csvparam <- "/mnt/zone2/studerf/param9.csv" # Contain study param. Group are the param for comparaison. Group correspond a collumn in ComparFile or File (For compare allsample vs Reference)
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


DeseqNorm <- function(se, outdir, lfc, pval, useAlpha, alpha, fit="basic"){
  
  #################################################################################################################################
  ################################################ Functions Deseq2 ###############################################################
  #################################################################################################################################
  
  scatterplot <- function(dds, outdir){
    library(dplyr)
    library(ggplot2)
    
    # The First scatterplot for see the normalisation count weight
    i <- 2
    while (i <= ncol(counts(dds, normalized=TRUE))) {
      png(file.path(outdir,paste(colnames(counts(dds, normalized=TRUE))[i],"scatterplot-deseqnormal.png",sep = "")), 1200, 1000, pointsize=20)
      df <- bind_rows(
        as_data_frame(log2(counts(dds, normalized=TRUE)[, c(1,i)]+1)) %>%
          mutate(transformation = "log2(Normalised Count + 1)"))
      colnames(df)[1:2] <- c("x", "y")  
      p <- ggplot(df, aes(x = x, y = y)) + geom_hex(bins = 80) +
        coord_fixed() + facet_grid( . ~ transformation) + geom_smooth(method='loess', size = 1.25, color = "yellow") + geom_smooth(method='lm', size = 0.5, color = "red") + geom_smooth(span = 0.01, color = "green", size = 0.25) + labs(x = colnames(counts(dds, normalized=TRUE))[1]) + labs(y = colnames(counts(dds, normalized=TRUE))[i])
      print(p)
      dev.off()
      i <- i+1
    }
    
    # The second scatterplot for see the raw count weight
    i <- 2
    while (i <= ncol(counts(dds, normalized=FALSE))) {
      png(file.path(outdir,paste(colnames(counts(dds, normalized=FALSE))[i],"scatterplot-rawcount.png",sep = "")), 1200, 1000, pointsize=20)
      df <- bind_rows(
        as_data_frame(log2(counts(dds, normalized=FALSE)[, c(1,i)]+1)) %>%
          mutate(transformation = "log2(Raw Count + 1)"))
      colnames(df)[1:2] <- c("x", "y")  
      p <- ggplot(df, aes(x = x, y = y)) + geom_hex(bins = 80) +
        coord_fixed() + facet_grid( . ~ transformation) + geom_smooth(method='loess', size = 1.25, color = "yellow") + geom_smooth(method='lm', size = 0.5, color = "red") + geom_smooth(span = 0.01, color = "green", size = 0.25) + labs(x = colnames(counts(dds, normalized=TRUE))[1]) + labs(y = colnames(counts(dds, normalized=FALSE))[i])
      print(p)
      dev.off()
      i <- i+1
    }
  }
  
  MAPlot <- function(dds, outdir){
    
    # The First MA Plot for see the normalisation count weight
    i <- 2
    while (i <= ncol(counts(dds, normalized=TRUE))) {
      png(file.path(outdir,paste(colnames(counts(dds, normalized=TRUE))[i],"MvA Plot Normalised Count",sep = "")), 1200, 1000, pointsize=20)
      mvaDF <- data.frame(log2(sqrt((counts(dds, normalized=TRUE)[,1])*(counts(dds, normalized=TRUE)[,i]))),log2((counts(dds, normalized=TRUE)[,i]+0.000001)/(counts(dds, normalized=TRUE)[,1])+0.000001))
      p <- plot(mvaDF,pch=20, cex=0.3,main=paste("MA plot ",colnames(counts(dds, normalized=TRUE))[1],"VS",colnames(counts(dds, normalized=TRUE))[i]," normalised count",sep = ""), xlab=paste("Log2(sqrt(",colnames(counts(dds, normalized=TRUE))[1],"*",colnames(counts(dds, normalized=TRUE))[i],")",sep = ""), ylab=paste("log2(",colnames(counts(dds, normalized=TRUE))[i],"/",colnames(counts(dds, normalized=TRUE))[1],")",sep = ""), col="blue")
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
    while (i <= ncol(counts(dds, normalized=FALSE))) {
      png(file.path(outdir,paste(colnames(counts(dds, normalized=FALSE))[i],"MvA Plot Raw Count",sep = "")), 1200, 1000, pointsize=20)
      mvaDF <- data.frame(log2(sqrt((counts(dds, normalized=FALSE)[,1])*(counts(dds, normalized=FALSE)[,i]))),log2((counts(dds, normalized=FALSE)[,i]+0.000001)/(counts(dds, normalized=FALSE)[,1]+0.000001)))
      p <- plot(mvaDF,pch=20, cex=0.3,main=paste("MA plot ",colnames(counts(dds, normalized=FALSE))[1],"VS",colnames(counts(dds, normalized=FALSE))[i]," raw count",sep = ""), xlab=paste("Log2(sqrt(",colnames(counts(dds, normalized=FALSE))[1],"*",colnames(counts(dds, normalized=FALSE))[i],")",sep = ""), ylab=paste("log2(",colnames(counts(dds, normalized=FALSE))[i],"/",colnames(counts(dds, normalized=FALSE))[1],")",sep = ""), col="blue")
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
  
  library(DESeq2)
  dds <- DESeqDataSet(se, design = ~ group)
  dds <- dds[ rowSums(counts(dds)) > 0, ]
  
  if (fit == "basic"){
    dds <- DESeq(dds)
  } else {
    dds <- DESeq(dds,fitType = c(fit))
  }
  scatterplot(dds, outdir)
  MAPlot(dds, outdir)
  
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
  data <- data.frame(datacount,datanorm,datares)
  i <- 1
  exp <- vector("character")
  while (i <= nrow(data)){
    if (data[i,6] > 0){
      exp <- c(exp, "up")
    } else if (data[i,6] < 0) {
      exp <- c(exp, "down")
    } else {
      exp <- c(exp, "-")
    }
    i <- i+1
  }
  data <- data.frame(data,exp)
  
  write.csv(counts(dds, normalized=FALSE), file = file.path(outdir,"RawCount.csv"))
  write.csv(counts(dds, normalized=TRUE), file = file.path(outdir,"NormCount.csv"))
  differential <- data.frame(counts(dds, normalized=FALSE),counts(dds, normalized=TRUE),as.data.frame(res)[,c(1:ncol(as.data.frame(res)))])
  write.csv(differential, file = file.path(outdir,"Deseq.csv"))
  write.csv(data, file = file.path(outdir,"DifferentialGenes.csv"))
  resOrderedDF <- as.data.frame(res[order(res$pvalue),])
  write.csv(resOrderedDF, file = file.path(outdir,"ResultOrder.csv"))
  
}

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

GenerColdata <- function(dataCounts,grp){
  group <- rep(grp,ncol(dataCounts))
  coldata <- data.frame(group)
  rownames(coldata) <- colnames(dataCounts)
  return(coldata)
}

CellnetExtract <- function(DiffGenFile, CellnetFile, outdirXP, lfc, pval){
  
  CellnetTable <- read.csv(CellnetFile, header = TRUE)
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

# Other quantile normalisation
quantileNorm <- function(rawcount,outdir){
  library(preprocessCore)
  normcounts <- normalize.quantiles(as.matrix(rawcount))
  # scatterplot(rawcount, normcount, outdir)
  # MAPlot(rawcount, normcount, outdir)
  return(normcounts)
}


deseqrld <- function(se, outdir, lfc, pval, useAlpha, alpha, fit="basic"){
  library(DESeq2)
  dds <- DESeqDataSet(se, design = ~ group)
  rld <- rlog(dds, blind = TRUE)
  AnnalData(se, abs(assay(rld)), outdir, lfc, pval, useAlpha, alpha, fit)
}

deseqvst <- function(se, outdir, lfc, pval, useAlpha, alpha, fit="basic"){
  library(DESeq2)
  dds <- DESeqDataSet(se, design = ~ group)
  vsd <- vst(dds, blind = TRUE)
  AnnalData(se, abs(assay(vsd)), outdir, lfc, pval, useAlpha, alpha, fit)
}


# Lowess normalization
lowess.normalizeXP <- function(counts, ff=2/3){
  normcounts <- as.matrix(counts[,1])
  i <- 2
  while (i <= ncol(counts)){
    normcounts <- cbind(normcounts,as.matrix(lowess.normalize(counts[,i],counts[,1],ff)))
    i <- i+1
  }
  return(abs(normcounts))
}

lowess.normalize <- function(x,y, ff=2/3){
  # x = log(cy3 or chip1) and y = log/(cy5 or chip2)
  na.point <- (1:length(x))[!is.na(x) & !is.na(y)]
  x <- x[na.point]; y <- y[na.point] 
  fit <- lowess(x+y, y-x, f=ff)
  
  diff.fit <- approx(fit$x,fit$y,x+y,ties=mean)
  out <- y - diff.fit$y
  return(out)  
}

lowessNorm <- function (dataCountsXP, ff=2/3){
  
  xDeno <- as.numeric(dataCountsXP[,1])
  
  mat <- matrix(nrow= nrow(dataCountsXP), ncol =ncol(dataCountsXP))
  for (i in 1:ncol(dataCountsXP)){
    mat[,i] <- as.numeric(dataCountsXP[,i])
  }
  
  #create a norm matrix
  matNorm <- matrix(nrow=nrow(dataCountsXP), ncol=ncol(dataCountsXP))
  matNorm[,1] <- xDeno
  for (i in 2:ncol(mat)){
    yNum <- as.numeric(mat[, i])
    Mi <-  log2((yNum+0.00001)/(xDeno+0.00001))
    Ai <- log2(sqrt(yNum* xDeno)+1)
    fit <- lowess(Ai,Mi,f=ff,delta = 0.01 * diff(range(Ai)))
    diff.fit <- approx(fit$x, fit$y, Ai, ties = mean)
    Mnorm <- Mi - diff.fit$y
    ynorm <- yNum*2^(-diff.fit$y)# no log 
    matNorm[,i] <- ynorm
  }
  
  return(abs(matNorm)) 
  
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

verif <- function(dataCountsXP,dataCountNorm,outdirXP){
  png(file.path(outdirXP,"normQ.effect.png"), 1200, 1000, pointsize=20)
  boxplot(data.frame(log2(dataCountsXP),log2(dataCountNorm)))
  dev.off()
  write.csv(dataCountsXP, file = file.path(outdirXP,"QRawCount.csv"))
  write.csv(dataCountNorm, file = file.path(outdirXP,"QNormCount.csv"))
  dir.create(file.path(outdirXP,"verif"), showWarnings = FALSE)
  scatterplot(dataCountsXP, dataCountNorm, file.path(outdirXP,"verif"))
  MAPlot(dataCountsXP, dataCountNorm, file.path(outdirXP,"verif"))
}

annalyses <- function(dataCountsXP, coldataXP,outdirXP){
  dir.create(outdirXP, showWarnings = FALSE)
  seXP <- SummarizedExperiment(assay=as.matrix(dataCountsXP), rowData=rownames(dataCountsXP), colData=coldataXP)
  seXP <- as(seXP,"RangedSummarizedExperiment")
  ######################################################################
  ################# Deseq2 Typical annalyse ############################
  outdirDS <- file.path(outdirXP,"Deseq2.basic")
  dir.create(outdirDS, showWarnings = FALSE)
  DeseqNorm(seXP, outdirDS, lfc, pval, useAlpha, alpha)
  CellnetExtract(file.path(outdirDS,"Deseq.csv"), CellnetFile, outdirDS, lfc, pval)
  ################ Deseq with local fit ################################
  #outdirDS <- file.path(outdirXP,"Deseq2.local")
  #dir.create(outdirDS, showWarnings = FALSE)
  #DeseqNorm(seXP, outdirDS, lfc, pval, useAlpha, alpha, "local")
  #CellnetExtract(file.path(outdirDS,"Deseq.csv"), CellnetFile, outdirDS, lfc, pval)
  ################# Deseq with parametric fit ##########################
  #outdirDS <- file.path(outdirXP,"Deseq2.param")
  #dir.create(outdirDS, showWarnings = FALSE)
  #DeseqNorm(seXP, outdirDS, lfc, pval, useAlpha, alpha, "parametric")
  #CellnetExtract(file.path(outdirDS,"Deseq.csv"), CellnetFile, outdirDS, lfc, pval)
  ######################################################################
  ################# Quantile Normalisation #############################
  #outdirQN <- file.path(outdirXP,"Quantil.Norm1")
  #dir.create(outdirQN, showWarnings = FALSE)
  #dataCountNorm <- quantileNorm(dataCountsXP,outdirQN)
  #verif(dataCountsXP,dataCountNorm,outdirQN)
  #AnnalData(seXP, dataCountNorm, outdirQN, lfc, pval, useAlpha, alpha)
  #CellnetExtract(file.path(outdirQN,"Deseq.csv"), CellnetFile, outdirQN, lfc, pval)
  ############## Another quantile normalisation ########################
  outdirQN <- file.path(outdirXP,"Quantil.Norm2")
  dir.create(outdirQN, showWarnings = FALSE)
  dataCountNorm <- quantile_normalisation(dataCountsXP,outdirQN)
  verif(dataCountsXP,dataCountNorm,outdirQN)
  AnnalData(seXP, dataCountNorm, outdirQN, lfc, pval, useAlpha, alpha)
  CellnetExtract(file.path(outdirQN,"Deseq.csv"), CellnetFile, outdirQN, lfc, pval)
  ######################################################################
  ############# Other normalisation deseq2 #############################
  #outdirDS <- file.path(outdirXP,"Deseq2.rld")
  #dir.create(outdirDS, showWarnings = FALSE)
  #deseqrld(seXP, outdirDS, lfc, pval, useAlpha, alpha)
  #CellnetExtract(file.path(outdirDS,"Deseq.csv"), CellnetFile, outdirDS, lfc, pval)
  ############## Another normalisation deseq2 ##########################
  #outdirDS <- file.path(outdirXP,"Deseq2.vst")
  #dir.create(outdirDS, showWarnings = FALSE)
  #deseqvst(seXP, outdirDS, lfc, pval, useAlpha, alpha)
  #CellnetExtract(file.path(outdirDS,"Deseq.csv"), CellnetFile, outdirDS, lfc, pval)
  ######################################################################
  ############# Lowess Normalization ###################################
  #span <- 2/3
  #for (i in 1:3){
  #  outdirLW <- file.path(outdirXP,paste("Lowess.Norm1",".Span",span))
  #  dir.create(outdirLW, showWarnings = FALSE)
  #  dataCountNorm <- lowess.normalizeXP(dataCountsXP, ff=span)
  #  verif(dataCountsXP,dataCountNorm,outdirLW)
  #  AnnalData(seXP, dataCountNorm, outdirLW, lfc, pval, useAlpha, alpha)
  #  CellnetExtract(file.path(outdirLW,"Deseq.csv"), CellnetFile, outdirLW, lfc, pval)
  #  ############## Another Lowess Normalization ##########################
  #  outdirLW <- file.path(outdirXP,paste("Lowess.Norm2",".Span",span))
  #  dir.create(outdirLW, showWarnings = FALSE)
  #  dataCountNorm <- lowessNorm(dataCountsXP, ff=span)
  #  verif(dataCountsXP,dataCountNorm,outdirLW)
  #  AnnalData(seXP, dataCountNorm, outdirLW, lfc, pval, useAlpha, alpha)
  #  CellnetExtract(file.path(outdirLW,"Deseq.csv"), CellnetFile, outdirLW, lfc, pval)
  #  span <- span/3
  #}
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
while (i <= nrow(compars)){
  group <- as.character(compars[i,as.vector(param$Group[1])])
  comparGroup <- compars[i,]
  i <- i+1
  while (i <= nrow(compars) && group == as.character(compars[i,as.vector(param$Group[1])])){
    comparGroup <- rbind(comparGroup,compars[i,])
    i <- i+1
  }
  dataCountsCompar <- runImport(comparGroup,countdir,"comp")
  coldatacomp <- GenerColdata(dataCountsCompar,"comp")
  dataCountsXP <- fusionCounts(dataCountsReferences,dataCountsCompar)
  coldataXP <- rbind(coldataref,coldatacomp)
  outdirXP <- file.path(outdirComp,group)
  dir.create(outdirXP, showWarnings = FALSE)
  
  annalyses(dataCountsXP, coldataXP,file.path(outdirXP,"raw"))
  ###############################################
  ########## Ajout de +1 au counts ##############
  # dataCountsXP <- dataCountsXP+1
  ###############################################
  ###############################################
  # annalyses(dataCountsXP, coldataXP,file.path(outdirXP,"add_1"))
  
}
