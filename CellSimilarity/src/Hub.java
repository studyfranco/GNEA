import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class Hub extends Node{
	
	public static Set<GOTerm> GOTermMapHub = new HashSet<>();
	public static Set<GOTerm> GOTermInAllHub = new HashSet<>();
	
    public List<Node> nodeCellInHub = new ArrayList<Node>();
    public List<Hub> hubCellInHub = new ArrayList<Hub>();
    public HashMap<Node, Integer> GenesPresence= new HashMap<>();
    public HashMap<GOTerm, Integer> GOTermPresence = new HashMap<>();
    public int NodeNumber = 0;
    public boolean clean;
	
    public Hub(String Name) {
    	super(Name);
    }
    
    public Hub(Node N) {
		// TODO Auto-generated constructor stub
		super(N);
	}
    
    public boolean InitHub(Node node) {
    	this.GOTerms = new HashSet<GOTerm>();
    	this.GOTermClean = new HashSet<GOTerm>();
    	this.GOTermPvalue = new HashMap<>();
    	this.GOTermSignificant = new HashMap<>();
        // GOTerm Node specific
    	this.GOTerms.addAll(node.GOTerms);
        this.GOTermPvalue.putAll(node.GOTermPvalue);
        this.GOTermSignificant.putAll(node.GOTermSignificant);
        this.GRN = node.GRN.clone();
        this.MRNet = node.MRNet.clone();
        
        this.nodeCellInHub.add(node);
        this.NodeNumber = 1;
    	return true;
    }
    
    public boolean InitHub(Hub hub) {
    	this.GOTerms = new HashSet<GOTerm>();
    	this.GOTermClean = new HashSet<GOTerm>();
    	this.GOTermPvalue = new HashMap<>();
    	this.GOTermSignificant = new HashMap<>();
    	
    	this.GOTerms.addAll(hub.GOTerms);
        this.GOTermPvalue.putAll(hub.GOTermPvalue);
        this.GOTermSignificant.putAll(hub.GOTermSignificant);
        this.GRN = hub.GRN.clone();
        this.MRNet = hub.MRNet.clone();
        
        this.GenesPresence.putAll(hub.GenesPresence);
        this.GOTermPresence.putAll(hub.GOTermPresence);
        this.NodeNumber = hub.NodeNumber;
        
        this.hubCellInHub.add(hub);
    	return true;
    }
    
    public boolean addNode(Node node) {
    	this.GOCommon(node);
    	
    	if (MinCommun == 100f) {
    		this.GRN = this.GRN.getCommon(node.GRN);
    		this.MRNet = this.MRNet.getCommon(node.MRNet);
    	} else {
        	this.GRN.fusionNetwork(node.GRN);
        	this.MRNet.fusionNetwork(node.MRNet);
        	for(Node gene : node.GRN.nodes) {
        		if (!this.GenesPresence.containsKey(gene)) {
        			this.GenesPresence.put(gene,1);
        		} else {
            		this.GenesPresence.put(gene, GenesPresence.get(gene)+1);
        		}
        	}
    	}
    	
    	nodeCellInHub.add(node);
    	this.NodeNumber++;
    	return true;
    }
    
    public boolean addNode(Hub hub) {
    	this.GOCommon(hub);
    	
    	if (MinCommun == 100f) {
    		this.GRN = this.GRN.getCommon(hub.GRN);
        	this.MRNet = this.MRNet.getCommon(hub.MRNet);
    	} else {
        	this.GRN.fusionNetwork(hub.GRN);
        	this.MRNet.fusionNetwork(hub.MRNet);
        	hub.GenesPresence.forEach((k, v) -> this.GenesPresence.merge(k, v, (v1, v2) -> v1 + v2));
    	}
    	
    	hubCellInHub.add(hub);
    	this.NodeNumber = this.NodeNumber + hub.NodeNumber;
    	return true;
    }
	
    public boolean saveHub(BufferedWriter bw, File hubFolder, BufferedWriter bw2, BufferedWriter bw3, BufferedWriter bw4, BufferedWriter bw5) {
    	if (!clean) {
    		this.cleanHub();
    		clean = true;
    	}
        try {
    		File netHub = null;
    		Double pval = new Double(0);
    		if (writeHubGRN) {
        		netHub = new File(hubFolder.getAbsolutePath() + File.separator + GRNFolderName + File.separator + this.name + "_GRN.tsv");
        		this.GRN.writeNetwork(netHub);
    		}
    		if (writeHubMRNet) {
        		netHub = new File(hubFolder.getAbsolutePath() + File.separator + MRNFolderName + File.separator + this.name + "_MRN.tsv");
        		this.MRNet.writeNetwork(netHub);
    		}
    		if (writeHubGOTermNetwork) {
    			this.SaveGoNet(hubFolder);
    			this.GONet = null;
    		}
    		
    		List<String> StringHubCellInHub = new ArrayList<String>();
    		for (Hub hubChild : hubCellInHub) {
    			bw.write(this.name + "\t" + hubChild.name + "\n");
    			bw5.write(this.name + "\t" + hubChild.name + "\n");
    			StringHubCellInHub.add(hubChild.name);
    		}
    		for (Node NodeChild : nodeCellInHub) {
    			bw.write(this.name + "\t" + NodeChild.name + "\n");
    		}
    		
    		bw2.write(this.name + "\t" + NodeNumber + "\t" + nodeCellInHub.size() + "\t"
    				+ hubCellInHub.size() + "\t" + this.GOTerms.size() + "\t" + this.GOTermClean.size() + "\t"
    				+ this.GRN.nodes.size() + "\t" + this.MRNet.nodes.size() + "\t" + String.join(",",StringHubCellInHub) + "\n");
    		
    		for (GOTerm GO : GOTerms) {
    			pval = this.GOTermPvalue.get(GO) / (double) this.NodeNumber;
            	if (log10Pval) {
            		pval = -10*Math.log10(pval);
            	}
    			bw3.write(this.name + "\t" + GO.Term + "\t" + pval.toString() + "\n");
    		}
    		
    		for (GOTerm GO : GOTermClean) {
    			pval = this.GOTermPvalue.get(GO) / (double) this.NodeNumber;
            	if (log10Pval) {
            		pval = -10*Math.log10(pval);
            	}
    			bw4.write(this.name + "\t" + GO.Term + "\t" + pval.toString() + "\n");
    		}
    		
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
		
    	return true;
    }
    
    public boolean NetGOClean(BufferedWriter bw, BufferedWriter bw2) {
    	Set<GOTerm> CleanGO = new HashSet<>();
    	Double pval = new Double(0);
    	try {
        	CleanGO.addAll(GOTermClean);
        	CleanGO.removeAll(GOTermInAllHub);
        	for (GOTerm GO : CleanGO) {
        		pval = this.GOTermPvalue.get(GO) / (double) this.NodeNumber;
            	if (log10Pval) {
            		pval = -10*Math.log10(pval);
            	}
        		bw2.write(this.name + "\t" + GO.Term + "\t" + pval.toString() + "\n");
        	}
        	CleanGO.addAll(GOTerms);
        	CleanGO.removeAll(GOTermInAllHub);
        	for (GOTerm GO : CleanGO) {
        		pval = this.GOTermPvalue.get(GO) / (double) this.NodeNumber;
            	if (log10Pval) {
            		pval = -10*Math.log10(pval);
            	}
        		bw.write(this.name + "\t" + GO.Term + "\t" + pval.toString() + "\n");
        	}
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
    	
    	
    	return true;
    }
    
    public boolean cleanHub() {
    	if (MinCommun == 100) {
    		
    	} else {
    		// Search the min simil in the hub
    		
    	}
    	
    	if (writeHubGOTermNetwork) {
            this.GONetCreate();
    	}
        this.CleanGO();
        GOTermMapHub.addAll(GOTerms);
        GOTermInAllHub.retainAll(GOTerms);
        this.GOClean = true;
        this.GOComp = true;
		if (writeHubGRN) {
	        this.GRN.NodesdegreeUpdate();
	        this.GRN.singleNodeDetector();
	        
		}
		if (writeHubMRNet) {
	        this.MRNet.NodesdegreeUpdate();
	        this.MRNet.singleNodeDetector();
		}
        return true;
    }
    
	public boolean GOCommon(Node N) {
		if (MinCommun == 100f) {
			this.GOTerms.retainAll(N.GOTerms);
		} else {
			for (GOTerm Term : N.GOTerms) {
				if (this.GOTermPresence.containsKey(Term)) {
					this.GOTermPresence.put(Term,this.GOTermPresence.get(Term) + 1);
				} else {
					this.GOTermPresence.put(Term, 1);
				}
			}
			
	    	this.GOTerms.addAll(N.GOTerms);
			Set<GOTerm> hs = new HashSet<>();
			hs.addAll(GOTerms);
			this.GOTerms.clear();
			this.GOTerms.addAll(hs);
			
			/** if (GOTerm.goodTree) {
				if (N.GOClean) {
					this.GOTermClean.addAll(N.GOTermClean);
					hs = new HashSet<>();
					hs.addAll(GOTermClean);
					this.GOTermClean.clear();
					this.GOTermClean.addAll(hs);
				}
			} */
	    	
		}
    	N.GOTermPvalue.forEach((k, v) -> this.GOTermPvalue.merge(k, v, (v1, v2) -> v1 + v2));
    	this.GOTermSignificant.putAll(N.GOTermSignificant);
    	if (!N.GOComp) {
    		this.GOComp = false;
    	}
    	if (!N.GOClean) {
    		this.GOClean = false;
    	}
    	return true;
    }
	
	public boolean GOCommon(Hub N) {
		if (MinCommun == 100f) {
			this.GOTerms.retainAll(N.GOTerms);
		} else {
	    	this.GOTerms.addAll(N.GOTerms);
			Set<GOTerm> hs = new HashSet<>();
			hs.addAll(this.GOTerms);
			this.GOTerms.clear();
			this.GOTerms.addAll(hs);
			
			/** if (GOTerm.goodTree) {
				if (N.GOClean) {
					hs = new HashSet<>();
					hs.addAll(this.GOTermClean);
					this.GOTermClean.clear();
					this.GOTermClean.addAll(hs);
				}
			} */
			this.GOTermSignificant.putAll(N.GOTermSignificant);
	    	N.GOTermPresence.forEach((k, v) -> this.GOTermPresence.merge(k, v, (v1, v2) -> v1 + v2));	
		}
    	N.GOTermPvalue.forEach((k, v) -> this.GOTermPvalue.merge(k, v, (v1, v2) -> v1 + v2));
    	if (!N.GOComp) {
    		this.GOComp = false;
    	}
    	if (!N.GOClean) {
    		this.GOClean = false;
    	}
    	return true;
    }

}
