"""Goal is to transform the following matrix:
  a b c
a 1 2 3
b 4 5 6
c 7 8 9

to:

a a 1
a b 2
a c 3
b a 4
...
c c 9

And simultaneously filter the output based on a threshold for column c.
"""

import sys
import argparse
import pandas as pd

def getColumns(matrixFile):
    first=True
    col1=[]
    col2=[]
    col3=[]
    with open(matrixFile, "r") as fin:
        for l in fin:
            if first:
                values=l.split()
                #write 1st column : aaabbbccc
                for v in values:
                    for i in range(len(values)):
                        col1.append(v)
                #write 2nd column : abcabcabc
                for i in range(len(values)):
                    for v in values:
                        col2.append(v)
                first=False
            else:
                #fill 3rd column with data
                for elt in l.split()[1:]:
                        col3.append(elt)
    return (col1, col2, col3)

def writeOutput(matrixFile, outputPath, thresholds):
    col1, col2, col3 = getColumns(matrixFile)
    thresList = [float(thres) for thres in thresholds.split(",")]
    for thres in thresList:
        with open(outputPath+"_"+str(thres)+".tsv", "w") as fout:
            fout.write("Cell x\tCell y\tSimilarity Index\n")
            zip1=zip(col1,col2)
            for a, b in zip(zip1, col3):
                #removes same file to same file comparisons
                if a[0]==a[1]:
                    continue
                if float(b)>=thres:
                    fout.write(a[0]+"\t"+a[1]+"\t"+b+"\n")

def newMethod(matrixFile, outputPath, thresholds):
    df = pd.DataFrame.from_csv(matrixFile, sep="\t", header=0, index_col=0)
    headers = df.columns.tolist()
    n=len(headers)
    thresList = [float(thres) for thres in thresholds.split(",")]
    for thres in thresList:
        with open(outputPath+"_"+str(thres)+".tsv", "w") as f:
            f.write("Cell x\tCell y\tSimilarity Index\n")
            for x in range(n):
                for y in range(n):
                    if x < y:
                        if df.iat[x,y] >= thres:
                            f.write(headers[x]+"\t"+headers[y]+"\t"+str(df.iat[x,y])+"\n")

if __name__=="__main__":
    parser = argparse.ArgumentParser(description='This converts a matrix to a table with each combination, \
        and filters the output based on thresholds. Also removes same file to same file comparisons', \
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("matrixFile", help="/path/to/matrixFile.tsv")
    parser.add_argument("output", help="/path/to/output")
    parser.add_argument("thresholds", help="Thresholds list, separated by commas. Example: 10,25,50")
    args = parser.parse_args()

    #writeOutput(args.matrixFile, args.output, args.thresholds)
    newMethod(args.matrixFile, args.output, args.thresholds)
    #MATRIX = "/mnt/zone2/studerf/Pipeline/SCNorm/results/Ref.H9.SC.Orga1A.lfc.1.pval.0.01/lessSC0/Mean/SingleCell/ResultTetra/tanimoto.tsv"
    #OUTPUTPATH = "/home/nicaises/Scripts/tanimoto/orga1A"
    #thresholds = "10,25,50"
    #writeOutput(MATRIX, OUTPUTPATH, thresholds)