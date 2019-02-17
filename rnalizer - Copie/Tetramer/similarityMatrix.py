"""
Goal: get the pairwise tanimoto index between every csv file in a folder, based on their TGs list.

Principle:
-create data matrix with n rows ; 1 for each file, containing the list of its distinct TGs
-initiate n*n results matrix
-create list of combinations of the data matrix rows: (0,1) (0,2) (1,2) if n=3
-feed the workers with the combinations and the data matrix

-worker job: return the given combination and the distance value

-fill the results matrix with the corresponding distance in positions [x,y] and [y,x]


Performance notes:
using loadData_boolean (with a list for tgList), testData: done in: 593.3096303939819s
using loadData_boolean (with a dict for tgList), testData: time to load data matrix: 12.000981092453003s
"""

import os
import time
import argparse
import numpy as np
import pandas as pd
from multiprocessing import Pool, cpu_count
from scipy.spatial.distance import rogerstanimoto

def loadData_boolean(folder, col, booleanMatrixName, linesToSkip, separator, coupure):
    """Assign each TG to an ID (an index in a list). Convert each row of the data matrix to a boolean array.
    Returns data matrix, data labels, sample size.
    (can be used with any values other than TGs)

    Pseudo code:
    init data matrix with n rows
    init TG list

    read each file
        for each TG in file:
            if TG not in TG list:
                add an element to TG list
                add a column (value=False) to every line in the matrix
    """
    n = len(os.listdir(folder))
    matrix = np.zeros((n,0), dtype=bool)
    emptyCol = np.zeros((n,1), dtype=bool)
    tgList = {}
    tgIndex = 0
    labels = []
    prevTg = ""

    for i, f in enumerate(os.listdir(folder)):
        labels.append(f[coupure:-4])
        with open(os.path.join(folder, f), "r") as fin:
            for k in range(linesToSkip):
                next(fin)
            for l in fin:
                try:
                    #tg = l.split(",")[col-1][1:-1] #[1:-1] to remove " from the csv data
                    tg = l.split(separator)[col-1] #those " were not standard
                except:
                    tg = l.strip()
                if tg is prevTg: #ignore duplicates in files
                    continue
                else:
                    prevTg = tg
                if tg not in tgList:
                    matrix = np.concatenate((matrix, emptyCol), axis=1)
                    tgList[tg] = tgIndex
                    tgIndex+=1
                matrix[i, tgList[tg]] = True

    if booleanMatrixName is not "":
        np.savetxt(booleanMatrixName, matrix, delimiter=',', header=",".join(tgList))
    return matrix, labels, n

def multi_arg_wrapper_tanimoto(args):
    """Unwrap the arguments tuple for the workers"""
    return worker_similarity_tanimoto(*args)
def worker_similarity_tanimoto(x, y, m):
    """returns result matrix coordinates and associated tanimoto similarity index"""
    return(x, y, np.sum(np.logical_and(m[x], m[y]),dtype=np.dtype(float))/np.sum(np.logical_or(m[x], m[y]),dtype=np.dtype(float)))

def multi_arg_wrapper_dice(args):
    """Unwrap the arguments tuple for the workers"""
    return worker_similarity_dice(*args)
def worker_similarity_dice(x, y, m):
    """returns result matrix coordinates and associated tanimoto similarity index"""
    return(x, y, (2.0*np.sum(np.logical_and(m[x], m[y]),dtype=np.dtype(float)))/(np.sum(m[y],dtype=np.dtype(float))+np.sum(m[x],dtype=np.dtype(float))))

def multi_arg_wrapper_internal(args):
    """Unwrap the arguments tuple for the workers"""
    return worker_similarity_internal(*args)
def worker_similarity_internal(x, y, m):
    """returns result matrix coordinates and associated tanimoto similarity index"""
    return(x, y, np.sum(np.logical_and(m[x], m[y]),dtype=np.dtype(float))/np.sum(m[x],dtype=np.dtype(float)))

def enum_tasks(n, matrix):
    """Generates the row combinations"""
    for x in range(n):
        for y in range(n):
            if x < y:
                yield(x,y, matrix)
def enum_tasks_square(n, matrix):
    """Generates the row combinations"""
    for x in range(n):
        for y in range(n):
            yield(x,y, matrix)

def general_similarity(start, resultMatrix, labels, separator, outputPath, thresholds, method):

    print("Time to compute the "+str(method)+" index matrix: "+str(time.time()-start)+"s")
    #to add a first column with labels
    df = pd.DataFrame(resultMatrix, columns=labels, index=labels)
    df.to_csv(path_or_buf=outputPath+"_"+str(method)+".tsv", sep=separator)

    # To write a cellular network file with a specific threshold
    if thresholds is not "":
        headers = df.columns.tolist()
        n=len(headers)
        try:
            thresList = [float(thres) for thres in thresholds.split(",")]
        except:
            thresList = [float(thresholds)]
        for thres in thresList:
            with open(outputPath+"_"+str(method)+"_"+str(thres)+".tsv", "w") as f:
                f.write("Cell x\tCell y\tSimilarity Index\n")
                for x in range(n):
                    for y in range(n):
                        if x < y:
                            if df.iat[x,y] >= thres:
                                f.write(headers[x]+"\t"+headers[y]+"\t"+str(df.iat[x,y])+"\n")

def compute_similarity(folder, col, outputPath, cores, chunkSize, booleanMatrixName, linesToSkip, separator, thresholds, methods, coupure):
    start = time.time()
    m, labels, n = loadData_boolean(folder, col, booleanMatrixName, linesToSkip, separator, coupure)
    print("Time to load the boolean data matrix: "+str(time.time()-start)+"s")
    resultMatrix = np.ones((n, n))

    if methods is not "":
        try:
            methodsList = [str(method) for method in methods.split(",")]
        except:
            methodsList = [str(methods)]
        for method in methodsList:
            pool = Pool(cores)
            start = time.time()

            if method == "tanimoto":
                for r in pool.imap(multi_arg_wrapper_tanimoto,enum_tasks(n,m), chunkSize):
                    resultMatrix[r[0]][r[1]] = r[2]
                    resultMatrix[r[1]][r[0]] = r[2]
                resultMatrix = resultMatrix*100
                general_similarity(start, resultMatrix, labels, separator, outputPath, thresholds, method)

            elif method == "dice":
                for r in pool.imap(multi_arg_wrapper_dice,enum_tasks(n,m), chunkSize):
                    resultMatrix[r[0]][r[1]] = r[2]
                    resultMatrix[r[1]][r[0]] = r[2]
                resultMatrix = resultMatrix*100
                general_similarity(start, resultMatrix, labels, separator, outputPath, thresholds, method)

            elif method == "internal":
                for r in pool.imap(multi_arg_wrapper_internal,enum_tasks_square(n,m), chunkSize):
                    resultMatrix[r[0]][r[1]] = r[2]
                resultMatrix = resultMatrix*100
                general_similarity(start, resultMatrix, labels, separator, outputPath, thresholds, method)

if __name__=="__main__":
    parser = argparse.ArgumentParser(description='This script parses a column of every csv files in a directory, \
        converts them to a boolean matrix, then computes the Tanimoto similarity index between each file combination. \
        Output is a csv matrix.', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("directory", help="Text file containing info for the network generation and the \
        Network_collection.php page.")
    parser.add_argument("column", type=int, help="csv files column to compare (e.g. enter 1 to compute the similarity \
        based on the first column of every csv file)")
    parser.add_argument("output", help="/path/to/output.tsv")
    parser.add_argument("-c","--cores", metavar='N', type=int, default=1, help="Number of CPUs to use")
    parser.add_argument("-cs","--chunkSize", metavar='N', type=int, default=10000, help="Number of jobs sent to each CPU at once")
    parser.add_argument("-sm","--saveBooleanMatrix", metavar='Name', default="", help="Enter an output path to save the boolean \
        matrix (csv format). The boolean matrix is not saved if left empty.")
    parser.add_argument("-sp","--separator", metavar='Separator', default="\t", help="Column separator in data files. Default:TAB")
    parser.add_argument("-sl","--skipLines", metavar='N', type=int, default=1, help="Number of lines to ignore at the start \
        of each csv (header size)")
    parser.add_argument("-ts","--thresholds", metavar='Thresholds', default="", help="Thresholds list, separated by commas. \
        Example: 10,25,50")
    parser.add_argument("-mt","--methods", metavar='Methods', default="tanimoto", help="Calculation similarity methods list, separated by commas. \
        Example: tanimoto,dice,jaccard")
    parser.add_argument("-ct","--coupure", metavar='Coupure', type=int, default=0, help="How long are your header for file you want cut. \
        Example: 14")
    args = parser.parse_args()

    start = time.time()
    compute_similarity(args.directory, args.column, args.output, args.cores, args.chunkSize, args.saveBooleanMatrix, \
            args.skipLines, args.separator, args.thresholds, args.methods, args.coupure)
    print("Script completed in: "+str(time.time()-start)+"s")
