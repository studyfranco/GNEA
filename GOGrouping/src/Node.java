import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.io.File;

/**
 * Created by cholley on 16/01/17.
 * Modified by Francois STUDER on 05/04/18.
 */

public class Node extends Container{
    public int UUID;
    public String name;
    public List<GOTerm> GOTerm = new ArrayList<GOTerm>(); // GOTerm Select by pvalue
    public List<GOTerm> GOTermAll = new ArrayList<GOTerm>();
    public List<GOTerm> GOTermClean = new ArrayList<GOTerm>();
    public HashMap<GOTerm, Boolean> GOTermNodes = new HashMap<>(); // Boolean is for the node are a Child or not.
    public HashMap<GOTerm, Float> GOTermPvalue = new HashMap<>();
    public HashMap<GOTerm, Integer> GOTermSignificant = new HashMap<>();
    public boolean GOComp = false;
    public boolean GOClean = false;
    public Network GONet = null;
    public static HashMap<GOTerm, Boolean> GOTermMapChild = new HashMap<>();
    private static int GUUID = 0;

    public Node(String name) {
        UUID = GUUID++;
        this.name = name;
        if (!nodesMap.containsKey(name)) {
        	nodesMap.put(name,this);
        }
    }
    
    public Node(Node N) { // This constructor are for the hub class. Hub are special, this based on node but have more specifications.
    	this.name= N.name;
    	this.GOTerm.addAll(N.GOTerm);
    	this.GOComp = N.GOComp;
    	this.GOTermNodes.putAll(N.GOTermNodes);
    	this.GOTermPvalue.putAll(N.GOTermPvalue);
    	this.GOTermSignificant.putAll(N.GOTermSignificant);
    	
    }
    
    public boolean GONode(File GOList) {
    	try {
    	BufferedReader br = null;
    	float pval = 0.00f;
    	br = new BufferedReader(new FileReader(GOList));
    	String line = br.readLine();
        while ((line = br.readLine()) != null) {
        	String Term [] = line.split("\t");
        	if (ontolo.equalsIgnoreCase(Term[0]) || ontolo.equalsIgnoreCase("all")) {
            	if (Term[5].equals("< 1e-30")) {
            		Term[5] = "1e-30";
            		pval = Float.parseFloat(Term[5]);
            	} else {
                	pval = Float.parseFloat(Term[5]);
            	}
                	if(GOTermMap.containsKey(Term[1])) {
                		if (pval < pvalueGOTerm) {
                			this.GOTerm.add(GOTermMap.get(Term[1]));
                			GOTermMapGood.put(GOTermMap.get(Term[1]), true);
                		}
                		this.GOTermAll.add(GOTermMap.get(Term[1]));
                		this.GOTermNodes.put(GOTermMap.get(Term[1]), true);
                		this.GOTermPvalue.put(GOTermMap.get(Term[1]), pval);
                		this.GOTermSignificant.put(GOTermMap.get(Term[1]), Integer.parseInt(Term[3]));
                	} else {
                		GOTerm newTerm = new GOTerm(Term[1],Term[0]);
                		if (pval < pvalueGOTerm) {
                			this.GOTerm.add(newTerm);
                			GOTermMapGood.put(newTerm, true);
                		}
                		this.GOTermAll.add(GOTermMap.get(Term[1]));
                		this.GOTermNodes.put(newTerm, true);
                		this.GOTermPvalue.put(newTerm, pval);
                		this.GOTermSignificant.put(newTerm, Integer.parseInt(Term[3]));
                		GOTermMap.put(Term[1], newTerm);
            	}
            }
        }
        br.close();
        } catch (IOException ex) {
            System.err.println(ex);
            return false;
        }
    	this.GOComp = true;
    	this.GOClean = false;
    	return true;
    }
    
    public String GOStringList() {
    	if (GOTerm == null) {
    		return "";
    	} else if(GOTerm.size() == 0) {
    		return "";
    	}
    	/** String ListTerm = GOTerm.get(0).Term;
    	
    	for (int ir=1; ir<GOTerm.size(); ir++) {
    		ListTerm = (ListTerm + "\t" + GOTerm.get(ir).Term);
    	} **/
    	
    	List<String> ListLine = new ArrayList<String>();
    	
    	for (int ir=0; ir<GOTerm.size(); ir++) {
    		ListLine.add(GOTerm.get(ir).Term);
    	}
    	
    	String ListTerm = String.join("\t",ListLine);
    	
    	return ListTerm;
    }
    
    public String GOCleanStringList() {
    	if (GOTerm == null) {
    		return "";
    	} else if(GOTerm.size() == 0) {
    		return "";
    	}
    	/** String ListTerm = GOTermClean.get(0).Term;
    	
    	for (int ir=1; ir<GOTermClean.size(); ir++) {
    		ListTerm = (ListTerm + "\t" + GOTermClean.get(ir).Term);
    	} **/
    	
    	List<String> ListLine = new ArrayList<String>();
    	
    	for (int ir=0; ir<GOTermClean.size(); ir++) {
    		ListLine.add(GOTermClean.get(ir).Term);
    	}
    	
    	String ListTerm = String.join("\t",ListLine);
    	return ListTerm;
    }
    
    public boolean GONetCreate() {
    	List<GOTerm> relation = null;
    	GONet = new Network();
    	for (GOTerm GO : this.GOTerm) {
    		relation = GO.getChild();
    		if (relation != null) {
    			relation.retainAll(GOTerm);
    			if (relation.size() > 0) {
            		for (GOTerm Child : relation ) {
            			GONet.addEdge(GO.Term,Child.Term);
            		}
    			} else {
        			relation = GO.getParents();
        			if ( relation == null) {
        				GONet.addNode(GO.Term);
        			} else {
        				relation.retainAll(GOTerm);
        				if (relation.size() == 0) {
        					GONet.addNode(GO.Term);
        				}
        			}
        		}
    		} else {
    			relation = GO.getParents();
    			if ( relation == null) {
    				GONet.addNode(GO.Term);
    			} else {
    				relation.retainAll(GOTerm);
    				if (relation.size() == 0) {
    					GONet.addNode(GO.Term);
    				}
    			}
    		}
    		relation = null;
    	}
    	return true;
    }
    
    public boolean CleanGO() {
    	List<GOTerm> toRemove = new ArrayList<GOTerm>();
    	List<GOTerm> relation = null;
    	List<GOTerm> littleChild = null;
    	GOTermClean.addAll(GOTerm);
    	System.out.println("Cleaning GOTerm for " + this.name + " :");
    	
    	for (GOTerm GO : this.GOTerm) {
    		relation = GO.getChild();
    		if (relation != null) {
    			relation.retainAll(GOTerm);
    			if (relation.size() > 0) {
    				boolean realChild = false;
    				for (GOTerm Child : relation) {
    					littleChild = Child.getChild();
    					if (littleChild == null) {
    						realChild = true;
    					}
    					else if (!littleChild.contains(GO)) {
    						realChild = true;
    					}
    				}
    				if (realChild) {
    					toRemove.add(GO);
    					this.GOTermNodes.put(GO, false);
    				} else {
    					GOTermMapChild.put(GO, true);
    				}
    			} else {
        			relation = GO.getParents();
        			// this.GOTermNodes.put(GO, true);
            		if (relation != null) {
            			relation.retainAll(GOTerm);
            			if (relation.size() == 0) {
            				System.out.println("The child " + GO.GOID + " searches his/her parents");
            			}
            			GOTermMapChild.put(GO, true);
            		}
    			}
    		} else {
    			relation = GO.getParents();
    			// this.GOTermNodes.put(GO, true);
        		if (relation != null) {
        			relation.retainAll(GOTerm);
        			if (relation.size() == 0) {
        				System.out.println("The child " + GO.GOID + " searches his/her parents");
        			}
        			GOTermMapChild.put(GO, true);
        		}
    		}
    		relation = null;
    	}
    	this.GOTermClean.removeAll(toRemove);
    	this.GOClean = true;
    	return true;
    }
    
    public Node clone() {
    	Node newNode = new Node(this.name);
    	newNode.GOTerm.addAll(this.GOTerm);
    	newNode.GOComp = true;
    	return newNode;
    }

    public boolean SaveGoNet() {
    	File result = new File(result_rep.getAbsolutePath() + File.separator + this.name + "GONet.tsv");
    	GONet.writeNetwork(result);
    	File attributs = new File(result_rep.getAbsolutePath() + File.separator + this.name + "GONetAttribut.tsv");
    	this.AttributsSaver(attributs);
    	return true;
    }
    
    public boolean AttributsSaver (File attributs) {
        try {
	        BufferedWriter bw = null;
	        bw = new BufferedWriter(new FileWriter(attributs));
        
	        bw.write("Cell" + "\t" + "Child" + "\t" + "pvalue" + "\t" + "Significant" + "\n");
	        
	        for (GOTerm GO : this.GOTerm) {
	            bw.write(GO.Term + "\t" + this.GOTermNodes.get(GO) + "\t" + this.GOTermPvalue.get(GO) + "\t" + this.GOTermSignificant.get(GO) + "\n");
	        }
	        
	        bw.flush();
			bw.close();
        
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
        return true;
    }
}
