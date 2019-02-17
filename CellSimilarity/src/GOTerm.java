import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.mariadb.*;


/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class GOTerm extends Container{

    static HashMap<GOTerm, HashMap<GOTerm, Boolean>> GOParents = new HashMap<>(); // This hash map contain a hashmap of all child for a GO term
    static HashMap<GOTerm, HashMap<GOTerm, Boolean>> GOChilds = new HashMap<>(); // This hash map contain a hashmap of all parents for one GO term
	static boolean goodTree = false;
	
	String Term;
	String ont;
	String GOID;
	String Name;
	
    public GOTerm(String Term, String Ont) {
        this.Term = Term;
        this.ont = Ont;
        String GO [] = Term.split(":");
        this.GOID = (GO[0] + ":" + GO[1]);
        this.Name = GO[2];
        if(GOIDTermMap.containsKey(this.GOID)) {
    		if (!GOIDTermMap.get(this.GOID).Term.equals(this.Term)) {
                    System.err.println("GOTerm with the same GOID have different GOTerm: " + this.GOID);
                    System.exit(1);
    		} else {
    			System.out.println("GOTerm with same term and GOID are create. " + this.Term + " Silent Error.");
    		}
    	} else {
    		GOIDTermMap.put(this.GOID, this);
    	}
    }
    
    public boolean addParent(GOTerm GO) {
        if (GOParents.containsKey(GO)) {
        	HashMap<GOTerm, Boolean> h = GOParents.get(GO);
        	if(!h.containsKey(this)) {
        		h.put(this, true);
        	}
        } else {
        	HashMap<GOTerm, Boolean> h = new HashMap<GOTerm, Boolean>();
        	h.put(this, true);
        	GOParents.put(GO, h);
        }
        return true;
    }
    
    public boolean addChild(GOTerm GO) {
        if (GOChilds.containsKey(GO)) {
        	HashMap<GOTerm, Boolean> h = GOChilds.get(GO);
        	if(!h.containsKey(this)) {
        		h.put(this, true);
        	}
        } else {
        	HashMap<GOTerm, Boolean> h = new HashMap<GOTerm, Boolean>();
        	h.put(this, true);
        	GOChilds.put(GO, h);
        }
        return true;
    }
    
    public List<GOTerm> getChild() {
    	//Set<GOTerm> keys = GOChilds.get(this).keySet();
    	//GOTerm[] Childs = keys.toArray(new GOTerm[keys.size()]);
    	if (GOParents.containsKey(this)) {
        	List<GOTerm> Childs = new ArrayList<>(GOParents.get(this).keySet());
        	return Childs;
    	} else {
    		return null;
    	}
    }
    
    public List<GOTerm> getParents() {
    	//Set<GOTerm> keys = GOParents.get(this).keySet();
    	//GOTerm[] Childs = keys.toArray(new GOTerm[keys.size()]);
        if (GOChilds.containsKey(this)) {
        	List<GOTerm> Parents = new ArrayList<>(GOChilds.get(this).keySet());
        	return Parents;
    	} else {
    		return null;
    	}
    }
    
    public static boolean treeGenerator() throws SQLException {
		GOTerm GO = null;
		String query = null;
		String ontology = null;
		Statement Connect = null;
		ResultSet rs = null;
    	try {
			Connection connection = DriverManager.getConnection("jdbc:mariadb://" + IPDB + "/GOR?user="+ userDB + "&password=" + passDB);
			Connect = connection.createStatement();
			for (String ident : GOTermMap.keySet()) {
				GO = GOTermMap.get(ident);
				query = "SELECT go_term.go_id, go_term.term FROM go_term " +
		                   "WHERE go_term.go_id = \"" + GO.GOID + "\"";
				rs = Connect.executeQuery(query);
				while(rs.next()) {
					GO.GOID = rs.getString("go_term.go_id");
					GO.Name = rs.getString("go_term.term");
					GO.Term = (GO.GOID + ":" + GO.Name);
				}
				ontology = GO.ont.toLowerCase();
				query = "SELECT child.go_id, child.term FROM go_term AS parents" +
		                   " INNER JOIN go_" + ontology + "_offspring ON parents._id = go_" + ontology + "_offspring._id " +
		                   "INNER JOIN go_term AS child ON child._id = go_" + ontology + "_offspring._offspring_id WHERE parents.go_id = \"" +
		                   GO.GOID + "\"";
				rs = Connect.executeQuery(query);
				while(rs.next()) {
					String parentsGO_id = rs.getString("child.go_id");
					String parentsTerm = rs.getString("child.term");
					if(GOIDTermMap.containsKey(parentsGO_id)) {
		                if (GOParents.containsKey(GO)) {
		                	HashMap<GOTerm, Boolean> l = GOParents.get(GO);
		                	if (l.containsKey(GOIDTermMap.get(parentsGO_id))) {
		                		// System.out.println("Database problem when you generate tree. Duplicate connexion");
		                	} else {
			                	l.put(GOIDTermMap.get(parentsGO_id),true);
			                	GOIDTermMap.get(parentsGO_id).Name = parentsTerm;
		                	}
		                } else {
		                	HashMap<GOTerm, Boolean> l = new HashMap<>();
		                	l.put(GOIDTermMap.get(parentsGO_id),true);
		                	GOIDTermMap.get(parentsGO_id).Name = parentsTerm;
		                	GOParents.put(GO, l);
		                }
		                ////////////////////////////////////////////////////////////////////////////////
		                if (GOChilds.containsKey(GOIDTermMap.get(parentsGO_id))) {
		                	HashMap<GOTerm, Boolean> l = GOChilds.get(GOIDTermMap.get(parentsGO_id));
		                	if (l.containsKey(GO)) {
		                		// System.out.println("Database problem when you generate tree. Duplicate connexion");
		                	} else {
			                	l.put(GO,true);
		                	}
		                } else {
		                	HashMap<GOTerm, Boolean> l = new HashMap<>();
		                	l.put(GO,true);
		                	GOChilds.put(GOIDTermMap.get(parentsGO_id), l);
		                }
					}
					// System.out.println("Parents of " + GO.Term + " :\t" + parentsGO_id + ":" + parentsTerm);
				}
				query = "SELECT parents.go_id, parents.term FROM go_term AS parents" +
		                   " INNER JOIN go_" + ontology + "_parents ON parents._id = go_" + ontology + "_parents._parent_id " +
		                   "INNER JOIN go_term AS child ON child._id = go_" + ontology + "_parents._id WHERE child.go_id = \"" +
		                   GO.GOID + "\"";
				rs = Connect.executeQuery(query);
				while(rs.next()) {
					String childGO_id = rs.getString("parents.go_id");
					String childTerm = rs.getString("parents.term");
					if(GOIDTermMap.containsKey(childGO_id)) {
		                if (GOChilds.containsKey(GO)) {
		                	HashMap<GOTerm, Boolean> l = GOChilds.get(GO);
		                	if (l.containsKey(GOIDTermMap.get(childGO_id))) {
		                		// System.out.println("Database problem when you generate tree. Duplicate connexion");
		                	} else {
			                	l.put(GOIDTermMap.get(childGO_id),true);
			                	GOIDTermMap.get(childGO_id).Name = childTerm;
		                	}
		                } else {
		                	HashMap<GOTerm, Boolean> l = new HashMap<>();
		                	l.put(GOIDTermMap.get(childGO_id),true);
		                	GOIDTermMap.get(childGO_id).Name = childTerm;
		                	GOChilds.put(GO, l);
		                }
		                ///////////////////////////////////////////////////////////////////////////////
		                if (GOParents.containsKey(GOIDTermMap.get(childGO_id))) {
		                	HashMap<GOTerm, Boolean> l = GOParents.get(GOIDTermMap.get(childGO_id));
		                	if (l.containsKey(GO)) {
		                		// System.out.println("Database problem when you generate tree. Duplicate connexion");
		                	} else {
			                	l.put(GO,true);
		                	}
		                } else {
		                	HashMap<GOTerm, Boolean> l = new HashMap<>();
		                	l.put(GO,true);
		                	GOParents.put(GOIDTermMap.get(childGO_id), l);
		                }
		                
					}
					// System.out.println("Child of " + GO.Term + " :\t" + childGO_id + ":" + childTerm);
				}
			}
			goodTree = true;
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
	        if (Connect != null) { Connect.close(); }
	    }
    	
    	return true;
    }
}
