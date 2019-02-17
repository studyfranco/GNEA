#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)<4) {
  stop("At least 4 argument must be supplied.\n", call.=FALSE)
}

CellnetFile <- "/home/studerf/mnt/Zone2/Pipeline/SCNorm/Human_Big_GRN_032014.csv"
TetraResultFolder <- "/home/studerf/mnt/Zone2/Pipeline/SCNorm/results/Ref.H9_SC.Orga1A_lfc.1_pval.0.1_Norm.Mean/SingleCell/pval.0.1_lfc.1/ResultTetra/Results"
outdir <- "/home/studerf/mnt/Zone2/Pipeline/SCNorm/results/Ref.H9_SC.Orga1A_lfc.1_pval.0.1_Norm.Mean/SingleCell/pval.0.1_lfc.1/ResultTetra"
pval <- 0.01
yield <- 1

CellnetFile <- args[1]
TetraResultFolder <- args[2]
outdir <- args[3]
pval <- as.numeric(args[4])
yield <- as.numeric(args[5])


dir.create(outdir, showWarnings = FALSE)
dir.create(file.path(outdir,"CoRegNetwork"), showWarnings = FALSE)
dir.create(file.path(outdir,"CoRegulListGenes"), showWarnings = FALSE)
listfileresult <- list.files(path = TetraResultFolder)
CellnetTable <- read.csv(CellnetFile, header = TRUE)
CellnetTable$TG <- toupper(CellnetTable$TG)
CellnetTable$TF <- toupper(CellnetTable$TF)
CellnetTable <- CellnetTable[CellnetTable$corr >= 0,]

after <- c()
before <- c()
listyield <- c()
listyieldechant100 <- c()

i <- 1
while (i <= length(listfileresult)){
  result <- read.table(file.path(TetraResultFolder,listfileresult[i]), header = TRUE, sep = "\t")
  before <- c(before,nrow(result))
  result <- result[result[,3] <= pval,]
  after <- c(after,nrow(result))
  result[,1] <- toupper(result[,1])
  if (nrow(result) > 0){
    if (nrow(result) > 100){
      listyieldechant100 <- c(listyieldechant100,result[,2])
    }
    listyield <- c(listyield,result[,2])
    write.table(result[,1,drop=FALSE], file = file.path(file.path(outdir,"CoRegulListGenes"),paste("CoReguloGenes",substr(listfileresult[i],14,nchar(listfileresult[i])-4),".tsv", sep = "")),row.names = FALSE, quote = FALSE, sep='\t')
    # j <- 1
    # rawConnex <- CellnetTable[CellnetTable$TF == result[j,1],]
    # j <- j+1
    # while(j <= nrow(result)){
    #  rawConnex <- rbind(rawConnex,CellnetTable[CellnetTable$TF == result[j,1],])
    #  j <- j+1
    # }
    # j <- 1
    # connexion <- rawConnex[rawConnex$TG == result[j,1],]
    # j <- j+1
    # while(j <= nrow(result)){
    #   connexion <- rbind(connexion,rawConnex[rawConnex$TG == result[j,1],])
    #   j <- j+1
    # }
    # if (nrow(connexion) > 0) {
    #   write.table(connexion, file = file.path(file.path(outdir,"CoRegNetwork"),paste("CoReg",substr(listfileresult[i],14,nchar(listfileresult[i])-4),".tsv", sep = "")),row.names = FALSE, quote = FALSE, sep='\t')
    # }
  }
  i <- i+1
}

after <- as.numeric(after)
before <- as.numeric(before)
resum <- data.frame(listfileresult,before,after)
colnames(resum) <- c("Files","Before_cut","After_cut")

png(file.path(outdir,"Regulom.scatterplot.png"), 1200, 1000, pointsize=20)
plot(resum[,2],resum[,3], main="Number of master regulators for each organoid cell before and after cut by p-value",xlab="Number of genes sent to Tetramer", ylab="Number of master regulators above p-value threshold", pch=19)
dev.off()

png(file.path(outdir,"Regulom.boxplot.png"), 1200, 1000, pointsize=20)
boxplot(resum[,3], main=paste("Boxplot about the number total master regulator below p-value ",pval,sep = ""))
dev.off()

if (length(listyield) > 0){
  png(file.path(outdir,"Yield.boxplot.png"), 1200, 1000, pointsize=20)
  boxplot(listyield, main=paste("Boxplot about the yield below p-value ",pval,sep = ""))
  dev.off()
}

if (length(listyieldechant100) > 0){
  png(file.path(outdir,"Yield.SampleWithMore100MR.boxplot.png"), 1200, 1000, pointsize=20)
  boxplot(listyieldechant100, main=paste("Boxplot about the yield below p-value ",pval," for sample with more than 100 MR",sep = ""))
  dev.off()
}

write.table(resum, file = file.path(outdir,"Resum.reg.tsv"),row.names = FALSE, quote = FALSE, sep='\t')