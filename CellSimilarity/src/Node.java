import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.io.File;

/**
 * Created by cholley on 16/01/17.
 * Modified by Francois STUDER on 05/04/18.
 */
public class Node extends Container{
    public String name;
    // GOTerm Node specific
    public Set<GOTerm> GOTerms; // GOTerm Select by pvalue
    public Set<GOTerm> GOTermClean; // All GOTerm who are design for child
    public HashMap<GOTerm, Double> GOTermPvalue; // Save all GOTerm and pvalue
    public HashMap<GOTerm, Integer> GOTermSignificant; // Save all GOTerm significant. Local, but can be general. In testing.
    public boolean GOComp;
    public boolean GOClean;
    public Network GONet;
    // Gene specific
    public Network GRN;
    public Network MRNet;

    public Node(String name) {
        this.name = name;
        if (!nodesMap.containsKey(name)) {
        	nodesMap.put(name,this);
        }
    }
    
    public Node(Node N) { // This constructor are for the hub class. Hub are special, this based on node but have more specifications.
    	this.name = N.name;
    	this.GOTerms.addAll(N.GOTerms);
    	this.GOTermPvalue.putAll(N.GOTermPvalue);
    	this.GOTermSignificant.putAll(N.GOTermSignificant);
    	this.GOComp = N.GOComp;
    	if (N.GRN != null) {
        	this.GRN = N.GRN.clone();
    	}
    	if (N.MRNet != null) {
        	this.MRNet = N.MRNet.clone();
    	}
    }
    
    public boolean GONode(File GOList) {
    	this.GOTerms = new HashSet<GOTerm>();
    	this.GOTermClean = new HashSet<GOTerm>();
    	this.GOTermPvalue = new HashMap<>();
    	this.GOTermSignificant = new HashMap<>();
    	try {
    	BufferedReader br = null;
    	double pval = 0.00f;
    	br = new BufferedReader(new FileReader(GOList));
    	String line = br.readLine();
        while ((line = br.readLine()) != null) {
        	String Term [] = line.split("\t");
        	if (ontolo.equalsIgnoreCase(Term[0]) || ontolo.equalsIgnoreCase("all")) {
            	if (Term[5].equals("< 1e-30")) {
            		Term[5] = "1e-30";
            		pval = Double.parseDouble(Term[5]);
            	} else {
                	pval = Double.parseDouble(Term[5]);
            	}
                if(GOTermMap.containsKey(Term[1])) {
                	if (pval < pvalueGOTerm) {
                		this.GOTerms.add(GOTermMap.get(Term[1]));
                	}
                	this.GOTermPvalue.put(GOTermMap.get(Term[1]), pval);
                	this.GOTermSignificant.put(GOTermMap.get(Term[1]), Integer.parseInt(Term[3]));
                } else {
                	GOTerm newTerm = new GOTerm(Term[1],Term[0]);
                	if (pval < pvalueGOTerm) {
                		this.GOTerms.add(newTerm);
                	}
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
		GOTermMapGood.addAll(this.GOTerms);
    	this.GOComp = true;
    	this.GOClean = false;
    	return true;
    }
    
    public boolean GRNLoad(File CellGRNFile) {
    	GRN = new Network(CellGRNFile);
    	return true;
    }
    
    public boolean MRLoad(File CellMRNetworkFile) {
    	MRNet = new Network(CellMRNetworkFile);
    	return true;
    }
    
    public String GOStringList() {
    	if (GOTerms == null) {
    		return "";
    	} else if(GOTerms.size() == 0) {
    		return "";
    	}
    	
    	List<String> ListLine = new ArrayList<String>();
    	for (GOTerm GO : GOTerms) {
    		ListLine.add(GO.Term);
    	}
    	String ListTerm = String.join("\t",ListLine);
    	
    	return ListTerm;
    }
    
    public String GOCleanStringList() {
    	if (GOTerms == null) {
    		return "";
    	} else if(GOTerms.size() == 0) {
    		return "";
    	}
    	
    	List<String> ListLine = new ArrayList<String>();
    	for (GOTerm GO : GOTermClean) {
    		ListLine.add(GO.Term);
    	}
    	String ListTerm = String.join("\t",ListLine);
    	
    	return ListTerm;
    }
    
    public boolean GONetCreate() {
    	List<GOTerm> relation = null;
    	GONet = new Network();
    	for (GOTerm GO : this.GOTerms) {
    		relation = GO.getChild();
    		if (relation != null) {
    			relation.retainAll(GOTerms);
    			if (relation.size() > 0) {
            		for (GOTerm Child : relation ) {
            			this.GONet.addEdge(GO.Term,Child.Term);
            		}
    			} else {
        			relation = GO.getParents();
        			if ( relation == null) {
        				this.GONet.addNode(GO.Term);
        			} else {
        				relation.retainAll(this.GOTerms);
        				if (relation.size() == 0) {
        					this.GONet.addNode(GO.Term);
        				}
        			}
        		}
    		} else {
    			relation = GO.getParents();
    			if ( relation == null) {
    				this.GONet.addNode(GO.Term);
    			} else {
    				relation.retainAll(this.GOTerms);
    				if (relation.size() == 0) {
    					this.GONet.addNode(GO.Term);
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
    	GOTermClean.addAll(this.GOTerms);
    	System.out.println("Cleaning GOTerm for " + this.name + " :");
    	
    	for (GOTerm GO : this.GOTerms) {
    		relation = GO.getChild();
    		if (relation != null) {
    			relation.retainAll(this.GOTerms);
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
    				}
    			} else {
        			relation = GO.getParents();
            		if (relation != null) {
            			relation.retainAll(GOTerms);
            			if (relation.size() == 0) {
            				System.out.println("The child " + GO.GOID + " searches his/her parents");
            			}
            		}
    			}
    		} else {
    			relation = GO.getParents();
        		if (relation != null) {
        			relation.retainAll(GOTerms);
        			if (relation.size() == 0) {
        				System.out.println("The child " + GO.GOID + " searches his/her parents");
        			}
        		}
    		}
    		relation = null;
    	}
    	this.GOTermClean.removeAll(toRemove);
    	GOTermMapChild.addAll(this.GOTermClean);
    	this.GOClean = true;
    	return true;
    }
    
    public Node clone() {
    	Node newNode = new Node(this.name);
    	newNode.GOTerms.addAll(this.GOTerms);
    	newNode.GOTermPvalue.putAll(this.GOTermPvalue);
    	newNode.GOTermSignificant.putAll(this.GOTermSignificant);
    	newNode.GOComp = true;
    	if (this.GRN != null) {
    		newNode.GRN = this.GRN.clone();
    	}
    	if (this.MRNet != null) {
    		newNode.MRNet = this.MRNet.clone();
    	}
    	return newNode;
    }

    public boolean SaveGoNet(File save_Folder) {
    	File result = new File(save_Folder.getAbsolutePath() + File.separator + GONetFolderName + File.separator + this.name + "_GOTermNetwork.tsv");
    	this.GONet.writeNetwork(result);
    	File attributs = new File(save_Folder.getAbsolutePath() + File.separator + GOAttFolderName + File.separator + this.name + "_GOTermNetAttribut.tsv");
    	this.AttributsSaver(attributs);
    	return true;
    }
    
    public boolean AttributsSaver (File attributs) {
        try {
	        BufferedWriter bw = null;
	        bw = new BufferedWriter(new FileWriter(attributs));
        
	        bw.write("Cell" + "\t" + "Child" + "\t" + "pvalue" + "\t" + "Significant" + "\n");
	        
	        for (GOTerm GO : this.GOTerms) {
	            bw.write(GO.Term + "\t" + this.GOTermClean.contains(GO) + "\t" + this.GOTermPvalue.get(GO) + "\t" + this.GOTermSignificant.get(GO) + "\n");
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
