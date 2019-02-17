import argparse
import pandas as pd

def main(matrixIn, matrixOut):
	df = pd.DataFrame.from_csv(matrixIn, sep="\t", header=0, index_col=0)
	headers = df.columns.tolist()
	indexes = ["c"+str(i+1) for i in range(len(headers))]

	relationFile = matrixOut[:-4] + "_headers.tsv"
	with open(relationFile, "w") as f:
		f.write("Index\tName\n")
		for i, h in enumerate(headers):
			f.write("c"+str(i+1)+"\t"+h+"\n")
	df.columns = indexes
	df.index = indexes
	df.to_csv(path_or_buf=matrixOut, sep="\t")

if __name__=="__main__":
    parser = argparse.ArgumentParser(description="Generates a matrix similar to input except headers are changed to indexes. \
    	Also generates a files containing the index->header relations.", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("input", help="/path/to/inputMatrix.tsv")
    parser.add_argument("output", help="/path/to/outputMatrix.tsv")
    args = parser.parse_args()
    main(args.input, args.output)