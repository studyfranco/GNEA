import java.io.File;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class ArgParser extends Container{

	static void parse(String[] args) {
	    
		IPDB = "192.168.25.161:3306";
		userDB = "";
		passDB = "";
		ontolo = "bp";
		
        	// Test arguments list
        	for(int i = 0; i < args.length;) {
        		switch (args[i]) {
        		case "":
        		    System.out.println("big BUG parsing args");
        		    System.exit(1);
        		    break;
        		case "-f":
        	    	i++;
        	    	cellMatrixFile = new File(args[i]);
        	        i++;
        	        break;
        		case "-out":
        			i++;
        			result_rep = new File(args[i]);
        		    GOCell_Folder = new File(result_rep + File.separator + "GO_Node");
        		    topologyFolder = new File(result_rep + File.separator + "Topology");
        			i++;
        			break; 
        		case "-GO":
        	    	i++;
        	    	GoFilesRep = new File(args[i]);
        	        i++;
        	        break;
        		case "-GRN":
        	    	i++;
        	    	GRNFilesRep = new File(args[i]);
        	        i++;
        	        break;
        		case "-MRN":
        	    	i++;
        	    	MRNetworkFilesRep = new File(args[i]);
        	        i++;
        	        break;
        		case "-Yield":
        	    	i++;
        	    	YieldFilesRep = new File(args[i]);
        	        i++;
        	        break;
        		case "-HGO":
        	    	i++;
        	    	debutFileGO = args[i];
        	        i++;
        	        break;
        		case "-HGRN":
        	    	i++;
        	    	debutFileGRN = args[i];
        	        i++;
        	        break;
        		case "-HMRN":
        	    	i++;
        	    	debutFileMRNetwork = args[i];
        	        i++;
        	        break;
        		case "-HYield":
        	    	i++;
        	    	debutFileYield = args[i];
        	        i++;
        	        break;
        		case "-CPC": // Mininum common each cell
        			i++;
        			MinCommun = Float.parseFloat(args[i]);
        	        i++;
        	        break;
        		case "-SMIN":
        			i++;
        			SimilMin = Float.parseFloat(args[i]);
        	        i++;
        	        break;
        		case "-SMAX":
        			i++;
        			SimilMax = Float.parseFloat(args[i]);
        	        i++;
        	        break;
        		case "-STEP":
        			i++;
        			Pas = Float.parseFloat(args[i]);
        	        i++;
        	        break;
        		case "-ONT":
        	    	i++;
        	    	ontolo = args[i];
        	        i++;
        	        break;
        		case "-PvalTerm":
        	    	i++;
        	    	pvalueGOTerm = Float.parseFloat(args[i]);
        	        i++;
        	        break;
        		case "-PvalCTerm":
        	    	i++;
        	    	pvalueGOChild = Float.parseFloat(args[i]);
        	        i++;
        	        break;
        		case "-IPDB":
        	    	i++;
        	    	IPDB = args[i];
        	        i++;
        	        break;
        		case "-UDB":
        	    	i++;
        	    	userDB = args[i];
        	        i++;
        	        break;
        		case "-PDB":
        	    	i++;
        	    	passDB = args[i];
        	        i++;
        	        break;
        		case "-EGON":
        			ExtractGOTermNode = true;
        			i++;
        			break;
        		case "-WGON":
        			WriteGOTermNode = true;
        			i++;
        			break;
        		case "-ETOH":
        			TopologyCompute = true;
        			i++;
        			break;
        		case "-WGRH":
        			writeHubGRN = true;
        			i++;
        			break;
        		case "-WMRH":
        			writeHubMRNet = true;
        			i++;
        			break;
        		case "-WGOH":
        			writeHubGOTermNetwork = true;
        			i++;
        			break;
        		case "-WAHN":
        			writeHubGOTermNetwork = true;
        			writeHubMRNet = true;
        			writeHubGRN = true;
        			i++;
        			break;
        		case "-log10":
        			log10Pval = true;
        			i++;
        			break;
        		case "-h":
        			System.out.println("This program are tetramer used with commands lines.\n" + 
        					"You must provide the following parameters when calling the function :\n" +
            				"absolute_path_to_cellnet_zipfile input_dir output_dir\n" + 
            				"or must provide the following parameters when calling the function with specials arguments:\n" +
            				"-net absolute_path_to_cellnet_zipfile -f input_dir -out output_dir\n" +
            				"in addition you can used this following parameters :\n" +
            				"-nhe for don't include Horizontal Edge\n" +
            				"-npv for don't cut starting node in the regulom with the p-value\n" +
            				"-nyd for don't cut starting node in the regulom with the yield\n" +
            				"-nrn for don't randomize the network\n" +
            				"-ncor for ignore the corelation in the network file\n");
        			System.exit(1);
        			break;
        		default :
        			System.out.println("Argument" + args[i] + "are not conform. It's skipped.");
        			i++;
        		}
        	}
    	if(cellMatrixFile == null || GoFilesRep == null || result_rep == null) {
    		System.out.println("You must provide the following parameters when calling the function :\n" +
    				"absolute_path_to_cellnet_zipfile input_dir output_dir\n");
    		System.out.println("or must provide the following parameters when calling the function with specials arguments:\n" +
    				"-net absolute_path_to_cellnet_zipfile -f input_dir -out output_dir\n");
    		System.exit(1);
    	}	
	}
}
