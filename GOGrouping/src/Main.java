import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedList;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class Main {

	public static void main(String[] args) throws SQLException {
		// TODO Auto-generated method stub
		String FileIn = args[0];
		String outdir = args[2];
		Container.debutFileGO = args[3];
		// Container.IPDB = "localhost:3306";
		Container.IPDB = "";
		Container.userDB = "";
		Container.passDB = "";
		Container.ontolo = "bp";
		Container.pvalueGOTerm = 0.01f;
		Container.pvalueGOChild = 0.01f;
		
		
		File netFile = new File(FileIn);
		Network net = new Network();
		if(!net.extractNetwork(netFile)) {
			System.out.println("Error with file: " + FileIn);
            System.exit(1);
		}
		
		File result_rep = new File(outdir + File.separator + "Results_GOHub");
		Container.result_rep = result_rep;
		result_rep.mkdir();
		File result = new File(result_rep.getAbsolutePath() + File.separator + "result" + ".tsv");
		File NumberGOFile = new File(result_rep.getAbsolutePath() + File.separator + "numberGOHub" + ".tsv");
		File MatrixFile = new File(result_rep.getAbsolutePath() + File.separator + "Matrix_Result" + ".tsv");
		
		File GoFilesRep = null;
		
		GoFilesRep = new File(args[1]);
		
		GOExtractor task = new GOExtractor();
		task.GoFilesRep = GoFilesRep;
		task.Net = net;
		task.HubAllNode();
		 
	    try {
	        BufferedWriter bw = null;
	        bw = new BufferedWriter(new FileWriter(result, false)); //second parameter is "append"
	        for (int ir=0; ir<task.HubList.size(); ir++) {
	        	bw.write(task.HubList.get(ir).name + "\t" + task.HubList.get(ir).GOStringList() + "\n");
	        }
	        bw.flush();
	        bw.close();
	        
	        bw = new BufferedWriter(new FileWriter(NumberGOFile, false)); //second parameter is "append"
	        bw.write("Node" + "\t" + "Number GO Term"+ "\t"+ "Number Child" + "\n");
	        for (int ir=0; ir<task.HubList.size(); ir++) {
	        	bw.write(task.HubList.get(ir).name + "\t" + task.HubList.get(ir).GOTerm.size()+ "\t" + task.HubList.get(ir).GOTermClean.size() + "\n");
	        }
	        bw.flush();
	        bw.close();
	        
	        
	    } catch (IOException e) {
	        e.printStackTrace();
	        System.exit(1);
	    }
        
	    try {
	        BufferedWriter bw = null;
	        bw = new BufferedWriter(new FileWriter(MatrixFile, false)); //second parameter is "append"
	        for (int ir=0; ir<task.HubList.size(); ir++) {
	        	bw.write(task.HubList.get(ir).name + "\t" + task.HubList.get(ir).GOCleanStringList() + "\n");
	        }
	        bw.flush();
	        bw.close();
	        
	    } catch (IOException e) {
	        e.printStackTrace();
	        System.exit(1);
	    }
	    
        System.exit(0);
	}

}
