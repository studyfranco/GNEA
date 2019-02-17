#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)<5) {
  stop("At least 5 argument must be supplied.\n", call.=FALSE)
}

library(FGNet)
library(foreach)
library(iterators)
library(parallel)
library(doParallel)

FilesFolder <- "/home/studerf/mnt/Zone4/rnalizer/SCNorm/results/Ref.H9_SC.Orga1A_lfc.1_pval.0.01_Norm.Mean/SingleCell/Tetrafiles"
outdir <- "/home/studerf/Test"
pval <- 0.01
ncol <- 1
Core <- 12
orga <- "Hs"
coupure <- 9

FilesFolder <- args[1]
outdir <- args[2]
pval <- as.numeric(args[3])
ncol <- as.numeric(args[4])
Core <- as.numeric(args[5])
coupure <- as.numeric(args[6])

listFilesFolder <- list.files(path = FilesFolder,include.dirs = FALSE, pattern=".tsv")

outdirGo <- file.path(outdir,"GoTerm")
dir.create(outdirGo, showWarnings = FALSE)
dir.create(file.path(outdirGo,"generated"), showWarnings = FALSE)
outdirGoAll <- file.path(outdirGo,"GoTermALL")
dir.create(outdirGoAll, showWarnings = FALSE)
outdirGoUP <- file.path(outdirGo,"GoTermUP")
dir.create(outdirGoUP, showWarnings = FALSE)
outdirGoDown <- file.path(outdirGo,"GoTermDown")
dir.create(outdirGoDown, showWarnings = FALSE)

GOTermExtract <- function(ListGenes,Listnomfile,folderOut,outdirGo,coupure,pval,Core){
  
  getGeneUniverse <- function(organism="Hs", geneIdType="SYMBOL") {
    data("organisms", envir = environment())
    organisms<- get("organisms", envir  = environment())
    if(organism %in% rownames(organisms)) 
    {
      orgPackage <- organisms[organism,"orgPackage"]
    } else{
      orgPackage <- organism
    }
    refPackage <- orgPackage
    dbPackage <- refPackage
    if(!suppressWarnings(library(dbPackage, character.only=TRUE, logical.return=TRUE, quietly=TRUE, pos = "package:base"))) stop(paste("Package", dbPackage, "is not available."))
    
    pkg.db <- eval(parse(text=dbPackage))
    columns(pkg.db)
    
    if(!geneIdType %in% columns(pkg.db)) stop(paste("geneIdType not available for ",dbPackage,". \nAvailable columns: ",paste(columns(pkg.db), collapse=", "), sep=""))
    
    return(keys(pkg.db, keytype=geneIdType))
  }
  genesUniverse <- getGeneUniverse()
  
  cl <- makeCluster(Core)
  registerDoParallel(cl)
  ListGoTerm <- foreach(j = 1:length(ListGenes), .packages = c("FGNet"), .inorder = FALSE) %dopar% {
    recogPercent <- sum(ListGenes[[j]] %in% genesUniverse)/length(ListGenes[[j]])
    if(recogPercent >= 0.1){
      feaResults_topGO <- fea_topGO(ListGenes[[j]], geneIdType="SYMBOL", pValThr=1, jobName=file.path(file.path(outdirGo,"generated"),paste("GOTerm_",Listnomfile[[j]],sep = "")))
      GOresult <- data.frame(lapply(feaResults_topGO[[3]][,c(2,6)], as.character),stringsAsFactors = FALSE)
      ## Remove line with NA,this line can be caused lot of problem.
      GOresult <- GOresult[rowSums(is.na(GOresult)) == 0,]
      rownames(GOresult) <- GOresult[,1]
      GOresult <- GOresult[,-1,drop=FALSE]
      ## It's a test for remove text value in the column.
      tester <- as.numeric(GOresult[,1])
      tester[is.na(tester)] = 0
      GOresult[,1] <- tester
      ####
      colnames(GOresult) <- c(substr(Listnomfile[[j]],coupure,nchar(Listnomfile[[j]])-4))
      # GOresult <- GOresult[GOresult[,1] < pval,,drop=FALSE]
      results <- feaResults_topGO[[3]]
      ## Remove line with NA,this line can be caused load problem.
      results <- results[rowSums(is.na(results)) == 0,]
      write.table(results, file = file.path(folderOut,paste("GOTerm_",Listnomfile[[j]],sep = "")), quote = FALSE, sep='\t',row.names=FALSE)
      list(as.matrix(GOresult))
    } else {
      vide <- c(1)
      vide <- matrix(data = vide,ncol = 1)
      rownames(vide) <- c("free")
      colnames(vide) <- c(substr(Listnomfile[[j]],coupure,nchar(Listnomfile[[j]])-4))
      list(vide)
    }
  }
  stopCluster(cl)
  return(ListGoTerm)
}

GenerateMatrix <- function(ListGoTerm,outdirGo,fileMat,pval,Core){
  ListGoTermTemps <- list(ListGoTerm[[1]][[1]])
  j <- 2
  while(j <= length(ListGoTerm)){
    ListGoTermTemps[[j]] <- ListGoTerm[[j]][[1]]
    j <- j+1
  }
  ListGoTermALL <- ListGoTermTemps
  cl <- makeCluster(Core)
  registerDoParallel(cl)
  while (length(ListGoTerm) > 1){
    nbjob <- as.integer(length(ListGoTerm)/2)
    results <- foreach(j = 1:nbjob, .inorder = FALSE) %dopar% {
      cellbool <- merge(ListGoTerm[[j*2-1]],ListGoTerm[[j*2]],all=TRUE,by="row.names")
      rownames(cellbool) <- cellbool[,1]
      cellbool <- cellbool[,-1,drop=FALSE]
      cellbool
    }
    if (length(ListGoTerm)%%2 > 0){
      ListGoTerm <- c(results,list(ListGoTerm[[nbjob*2+1]]))
    } else {
      ListGoTerm <- results
    }
  }
  stopCluster(cl)
  
  cellGOTerm <- as.matrix(ListGoTerm[[1]])
  cellGOTerm[is.infinite(cellGOTerm)] = 1
  cellGOTerm[is.na(cellGOTerm)] = 1
  cellGOTerm <- cellGOTerm[rowSums(cellGOTerm < pval) > 0,,drop=FALSE]
  
  write.table(cellGOTerm, file = file.path(outdirGo,fileMat), quote = FALSE, sep='\t',col.names=NA)
}

ListGenes <-list()
ListGenesUP <-list()
ListGenesDown <-list()
Listnomfile <- list()
i <- 1
while (i <= length(listFilesFolder)){
  file <- read.table(file.path(FilesFolder,listFilesFolder[i]), header = TRUE, sep = "\t",stringsAsFactors = FALSE)
  Listnomfile[[i]] <- listFilesFolder[i]
  ListGenes[[i]] <- file[,1]
  ListGenesUP[[i]] <- file[file[,2]>0,1]
  ListGenesDown[[i]] <- file[file[,2]<0,1]
  i <- i+1
}

GOgenes <- GOTermExtract(ListGenes,Listnomfile,outdirGoAll,outdirGo,coupure,pval,Core)
GenerateMatrix(GOgenes,outdirGo,"AllGeneMatrix.tsv",pval,Core)
GOgenesUP <- GOTermExtract(ListGenesUP,Listnomfile,outdirGoUP,outdirGo,coupure,pval,Core)
GenerateMatrix(GOgenesUP,outdirGo,"UPGeneMatrix.tsv",pval,Core)
GOgenesDOWN <- GOTermExtract(ListGenesDown,Listnomfile,outdirGoDown,outdirGo,coupure,pval,Core)
GenerateMatrix(GOgenesDOWN,outdirGo,"DOWNGeneMatrix.tsv",pval,Core)

unlink(file.path(outdirGo,"generated"), recursive = TRUE)