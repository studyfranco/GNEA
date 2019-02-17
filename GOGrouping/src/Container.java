import java.io.File;
import java.util.HashMap;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class Container {
    public static HashMap<String, GOTerm> GOTermMap = new HashMap<>();
    public static HashMap<String, Node> nodesMap = new HashMap<>(); // Node list for all network. Don't recreate node.
    public static HashMap<Node, HashMap<Node, Edge>> edgesMap = new HashMap<>(); // Edges list for all network. Don't recreate edges.
    public static HashMap<String, GOTerm> GOIDTermMap = new HashMap<>();
    public static HashMap<GOTerm, Boolean> GOTermMapGood = new HashMap<>();
    public static float pvalueGOTerm = 0.01f;
    public static float pvalueGOChild = 0.01f;
    public static String ontolo = "all"; 
    public static File result_rep = null;
    public static String debutFileGO = null;
    public static String IPDB = null;
    public static String userDB = null;
    public static String passDB = null;
}
