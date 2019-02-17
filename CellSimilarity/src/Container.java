import java.io.File;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class Container {
    public static HashMap<String, Node> nodesMap = new HashMap<>(); // Node list for all network. Don't recreate node.
    public static HashMap<Node, HashMap<Node, Edge>> edgesMap = new HashMap<>(); // Edges list for all network. Don't recreate edges.
    public static HashMap<Node, Set<Edge>> nodeEdgesTargetMap = new HashMap<>(); // List edges for all nodes in all network
    
    public static HashMap<String, GOTerm> GOTermMap = new HashMap<>();
    public static HashMap<String, GOTerm> GOIDTermMap = new HashMap<>();
    public static Set<GOTerm> GOTermMapGood = new HashSet<>();
    public static Set<GOTerm> GOTermMapChild = new HashSet<>();

    // Parameters
    public static File cellMatrixFile = null;
    
    public static String IPDB = null;
    public static String userDB = null;
    public static String passDB = null;
    
    public static File GoFilesRep = null;
    public static File GRNFilesRep = null;
    public static File MRNetworkFilesRep = null;
    public static File YieldFilesRep = null;
	
    // Folder to save results
    public static File result_rep = null;
    public static File GOCell_Folder = null;
    public static File topologyFolder = null;
    
    public static String debutFileGO = "";
    public static String debutFileGRN = "";
    public static String debutFileMRNetwork = "";
    public static String debutFileYield = "";

    public static Float MinCommun = 100f;
    public static Float SimilMin = 0f;
    public static Float SimilMax = 100f;
    public static Float Pas = 0.5f;
    
    public static String ontolo = "all";
    public static double pvalueGOTerm = 0.01;
    public static double pvalueGOChild = 0.01;
    
    public static boolean ExtractGOTermNode = false;
    public static boolean TopologyCompute = false;
    
    public static boolean log10Pval = false;
    
    public static boolean WriteGOTermNode = false;
    public static boolean writeHubGRN = false;
    public static boolean writeHubMRNet = false;
    public static boolean writeHubGOTermNetwork = false;
    
    // Not USED Arguments
    public static int REGULATION_POSITIVE = 1;
    public static int REGULATION_NEGATIVE = 1;
    public static int ALL_REGULATION = 0;
    
    // GeneralParameters
    public static String GONetFolderName = "GONet";
    public static String GOAttFolderName = "GOAttributs";
    public static String GRNFolderName = "GRN";
    public static String MRNFolderName = "MR";
}
