#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)<6) {
  stop("At least five argument must be supplied.\n", call.=FALSE)
}

genomeRef <- "/home/studerf/mnt/Zone2/rnalizer/references/annotation/GRCh37.gtf" # Where the reference genome are
bamfile <- "/home/studerf/mnt/Zone2/rnalizer/4alignement/temp/SRR3603424Aligned.out.bam" # Where bam files are
Core <- 6 # Number core used
outdir <- "/home/studerf"
XPtype <- "Single"
samplename <- "SRR3603424"

bamfile <- args[1]
samplename <- args[2]
XPtype <- args[3]
genomeRef <- args[4]
Core <- as.numeric(args[5])
outdir <- args[6]

library(Rsamtools)
library(BiocParallel)

#register(SerialParam()) # If you want obligatory used one core
register(MulticoreParam(workers = Core))

# For each file we execute this list of operation
# We take the first file on the list, and create a BamFileList Object
bamfile <- BamFileList(bamfile, yieldSize=200000000)
# We test if the good reference genome are used
library(GenomicFeatures)
# Load the reference genome. The generation of the localisation are create with : file.path(dirGref,paste(Gref,".gtf", sep = ""))
txdb <- makeTxDbFromGFF(genomeRef, format = "gtf", circ_seqs = character())
ebg <- exonsBy(txdb, by="gene")
library(BiocParallel)
library(GenomicAlignments)

if (XPtype == "Single"){
  se <- summarizeOverlaps(features=ebg, reads=bamfile,
                          mode="Union",
                          singleEnd=TRUE, #Definis sur cela est du pair end ou du single end. Pair end s'utilise avec fragments=TRUE
                          ignore.strand=TRUE) #strand-specific or not. This experiment was not strand-specific so we set ignore.strand to TRUE.
} else if(XPtype == "Paired"){
  se <- summarizeOverlaps(features=ebg, reads=bamfile,
                          mode="Union",
                          singleEnd=FALSE, # Definis sur cela est du pair end ou du single end. 
                          fragments=TRUE, # Pair end s'utilise avec fragments=TRUE
                          ignore.strand=TRUE) #strand-specific or not. This experiment was not strand-specific so we set ignore.strand to TRUE.
}

write.csv(assays(se)$counts, file = file.path(outdir,paste(samplename,".csv", sep = "")) )

write(paste(samplename,"\t",genomeRef, sep = ""),file = "countList.csv",append = TRUE)
