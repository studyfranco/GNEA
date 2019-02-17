import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
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

public class NetTopology extends Container{

	Network CellNetwork = null;
	List<Hub> HubList = new ArrayList<Hub>();
	HashMap<Node,Hub> NodeHub = new HashMap<>();
	
	public NetTopology() {
		
	}
	
	public boolean topologyCreator() {
	    for (float simil=SimilMax; simil >= SimilMin;simil = simil-Pas) {
	    	this.HubCreator(simil+Pas,simil);
	    }
		return true;
	}
	
	public boolean writeTopology() {
		File HubFolder = new File(topologyFolder.getAbsolutePath() + File.separator + "HubInformations");
		HubFolder.mkdir();
		File netHub = null;
		if (writeHubGRN) {
			netHub = new File(HubFolder.getAbsolutePath() + File.separator + GRNFolderName);
			netHub.mkdir();
		}
		if (writeHubMRNet) {
			netHub = new File(HubFolder.getAbsolutePath() + File.separator + MRNFolderName);
			netHub.mkdir();
		}
		if (writeHubGOTermNetwork) {
			netHub = new File(HubFolder.getAbsolutePath() + File.separator + GONetFolderName);
			netHub.mkdir();
			netHub = new File(HubFolder.getAbsolutePath() + File.separator + GOAttFolderName);
			netHub.mkdir();
		}
		
		GOTermMapChild = new HashSet<>();
		Hub.GOTermMapHub = new HashSet<>();
		Hub.GOTermInAllHub = new HashSet<>();
		Hub.GOTermInAllHub.addAll(GOTermMap.values());
		
		try {
	        BufferedWriter bw = null;
	        bw = new BufferedWriter(new FileWriter(topologyFolder.getAbsolutePath() + File.separator + "topologyNetwork.tsv"));
	        bw.write("HubGeneral" + "\t" + "HubSpecific" + "\n");
	        
	        BufferedWriter bw2 = null;
	        bw2 = new BufferedWriter(new FileWriter(topologyFolder.getAbsolutePath() + File.separator + "HubCarac.tsv"));
	        bw2.write("Hub" + "\t" + "Nodes_Total" + "\t" + "Nodes " + "\t" + "Hubs" + "\t" + "GOTerms" + "\t" + "GOChild" + "\t" + "GenesGRN" + "\t" + "MR"+ "\t" + "Hub_Compos"+ "\n");
	        
	        BufferedWriter bw3 = null;
	        bw3 = new BufferedWriter(new FileWriter(topologyFolder.getAbsolutePath() + File.separator + "GOTermNetwork.tsv"));
	        bw3.write("Hub" + "\t" + "GOTerm" + "\t" + "pvalue" + "\n");
	        
	        BufferedWriter bw4 = null;
	        bw4 = new BufferedWriter(new FileWriter(topologyFolder.getAbsolutePath() + File.separator + "GOChildNetwork.tsv"));
	        bw4.write("Hub" + "\t" + "GOTerm" + "\t" + "pvalue" + "\n");
	        
	        BufferedWriter bw5 = null;
	        bw5 = new BufferedWriter(new FileWriter(topologyFolder.getAbsolutePath() + File.separator + "GOTermNetworkClean.tsv"));
	        bw5.write("Hub" + "\t" + "GOTerm" + "\t" + "pvalue" + "\n");
	        
	        BufferedWriter bw6 = null;
	        bw6 = new BufferedWriter(new FileWriter(topologyFolder.getAbsolutePath() + File.separator + "GOChildNetworkClean.tsv"));
	        bw6.write("Hub" + "\t" + "GOTerm" + "\t" + "pvalue" + "\n");
	        
	        BufferedWriter bw7 = null;
	        bw7 = new BufferedWriter(new FileWriter(topologyFolder.getAbsolutePath() + File.separator + "HubNetwork.tsv"));
	        bw7.write("HubGeneral" + "\t" + "HubSpecific" + "\n");
	        
			for (Hub hub : HubList) {
				// Saving Hub information
				hub.saveHub(bw,HubFolder,bw2,bw3,bw4,bw7);
				
			}
	        
	        bw.flush();
			bw.close();
			bw2.flush();
			bw2.close();
	        bw3.flush();
			bw3.close();
			bw4.flush();
			bw4.close();
			bw7.flush();
			bw7.close();
			
	        Matrix GOMat = new Matrix();
	        Matrix GOMatChild = new Matrix();
	        Matrix GOPresenceMat = new Matrix();
	        Matrix GOPresenceMatChild = new Matrix();
	    	File MatrixFileChild = new File(topologyFolder.getAbsolutePath() + File.separator + "GOChildMatrix" + ".tsv");
	    	File MatrixFile = new File(topologyFolder.getAbsolutePath() + File.separator + "GOMatrix" + ".tsv");
	    	File MatrixFilePresence = new File(topologyFolder.getAbsolutePath() + File.separator + "GOPresenceMatrix" + ".tsv");
	    	File MatrixFilePresenceChild = new File(topologyFolder.getAbsolutePath() + File.separator + "GOChildPresenceMatrix" + ".tsv");
	    	Double pval = new Double(0);
			
			List<GOTerm> ListGOTermChild = new ArrayList<>(GOTermMapChild);
			List<GOTerm> ListGOTermHub = new ArrayList<>(Hub.GOTermMapHub);
	        for (Hub hub : HubList) {
	        	for (int is=0; is<ListGOTermChild.size(); is++) {
	        		if (hub.GOTermPvalue.get(ListGOTermChild.get(is)) != null) {
	        			pval = hub.GOTermPvalue.get(ListGOTermChild.get(is)) / (double) hub.NodeNumber;
	                	if (log10Pval) {
	                		pval = -10*Math.log10(pval);
	                	}
	        			GOMatChild.insertValue(hub.name, ListGOTermChild.get(is).Term, pval.toString());
	        		}
	        		if (hub.GOTerms.contains(ListGOTermChild.get(is))) {
	        			GOPresenceMatChild.insertValue(hub.name, ListGOTermChild.get(is).Term, "1");
	        		} else {
	        			GOPresenceMatChild.insertValue(hub.name, ListGOTermChild.get(is).Term, "0");
	        		}
	        	}
	        	for (int is=0; is<ListGOTermHub.size(); is++) {
	        		if (hub.GOTermPvalue.get(ListGOTermHub.get(is)) != null) {
	        			pval = hub.GOTermPvalue.get(ListGOTermHub.get(is)) / (double) hub.NodeNumber;
	                	if (log10Pval) {
	                		pval = -10*Math.log10(pval);
	                	}
	        			GOMat.insertValue(hub.name, ListGOTermHub.get(is).Term, pval.toString());
	        		}
	        		if (hub.GOTerms.contains(ListGOTermHub.get(is))) {
	        			GOPresenceMat.insertValue(hub.name, ListGOTermHub.get(is).Term, "1");
	        		} else {
	        			GOPresenceMat.insertValue(hub.name, ListGOTermHub.get(is).Term, "0");
	        		}
	        	}
	        	hub.NetGOClean(bw5,bw6);
	        }
			
			bw5.flush();
			bw5.close();
			bw6.flush();
			bw6.close();
			
			GOMatChild.writeMatrix(MatrixFileChild);
			GOMat.writeMatrix(MatrixFile);
			GOPresenceMatChild.writeMatrix(MatrixFilePresenceChild);
			GOPresenceMat.writeMatrix(MatrixFilePresence);
        
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
		
		return true;
	}
	
	public boolean HubCreator(float similarityMax, float similarityMin) {
		String StringSimili = Float.toString(similarityMax) + "-" + Float.toString(similarityMin);
		int nbNewHub = 0;
		Set<Hub> currentHub = new HashSet<Hub>();
		List<Edge> connectivity = new ArrayList<Edge>(CellNetwork.getEdgesIn(similarityMax,similarityMin));
		for (Edge connexion : connectivity) {
			if (NodeHub.containsKey(connexion.nodeSource)) {
				Hub hubSource = NodeHub.get(connexion.nodeSource);
				if (NodeHub.containsKey(connexion.nodeTarget)) {
					Hub hubTarget = NodeHub.get(connexion.nodeTarget);
					if(hubSource == hubTarget) {
						
					} else if (currentHub.contains(hubSource) && currentHub.contains(hubTarget)){
						for (Hub oldHub : hubTarget.hubCellInHub) {
							hubSource.addNode(oldHub);
							this.NodeHubModificator(oldHub, hubSource);
						}
						for (Node oldNode : hubTarget.nodeCellInHub) {
							hubSource.addNode(oldNode);
							this.NodeHub.put(oldNode, hubSource);
						}
						currentHub.remove(hubTarget);
					} else if(currentHub.contains(hubSource)) {
						hubSource.addNode(hubTarget);
						this.NodeHubModificator(hubTarget, hubSource);
					} else if(currentHub.contains(hubTarget)) {
						hubTarget.addNode(hubSource);
						this.NodeHubModificator(hubSource, hubTarget);
					} else {
						Hub newCurentHub = new Hub("Hub_" + StringSimili + "_" + Integer.toString(nbNewHub));
						newCurentHub.InitHub(hubSource);
						newCurentHub.addNode(hubTarget);
						this.NodeHubModificator(hubSource, newCurentHub);
						this.NodeHubModificator(hubTarget, newCurentHub);
						currentHub.add(newCurentHub);
						nbNewHub++;
					}
				} else {
					if(currentHub.contains(hubSource)) {
						hubSource.addNode(connexion.nodeTarget);
						this.NodeHub.put(connexion.nodeTarget, hubSource);
					} else {
						Hub newCurentHub = new Hub("Hub_" + StringSimili + "_" + Integer.toString(nbNewHub));
						newCurentHub.InitHub(hubSource);
						newCurentHub.addNode(connexion.nodeTarget);
						this.NodeHubModificator(hubSource, newCurentHub);
						this.NodeHub.put(connexion.nodeTarget, newCurentHub);
						currentHub.add(newCurentHub);
						nbNewHub++;
					}
				}
			} else {
				if (NodeHub.containsKey(connexion.nodeTarget)) {
					Hub hubTarget = NodeHub.get(connexion.nodeTarget);
					if(currentHub.contains(hubTarget)) {
						hubTarget.addNode(connexion.nodeSource);
						this.NodeHub.put(connexion.nodeSource, hubTarget);
					} else {
						Hub newCurentHub = new Hub("Hub_" + StringSimili + "_" + Integer.toString(nbNewHub));
						newCurentHub.InitHub(connexion.nodeSource);
						newCurentHub.addNode(hubTarget);
						this.NodeHub.put(connexion.nodeSource, newCurentHub);
						this.NodeHubModificator(hubTarget, newCurentHub);
						currentHub.add(newCurentHub);
						nbNewHub++;
					}
				} else {
					Hub newCurentHub = new Hub("Hub_" + StringSimili + "_" + Integer.toString(nbNewHub));
					newCurentHub.InitHub(connexion.nodeSource);
					newCurentHub.addNode(connexion.nodeTarget);
					this.NodeHub.put(connexion.nodeSource, newCurentHub);
					this.NodeHub.put(connexion.nodeTarget, newCurentHub);
					currentHub.add(newCurentHub);
					nbNewHub++;
				}
			}
		}
		this.HubList.addAll(currentHub);
		return true;
	}
	
	public boolean NodeHubModificator(Hub hubSource, Hub newHub) {
		for (Node node : hubSource.nodeCellInHub) {
			this.NodeHub.put(node, newHub);
		}
		for (Hub oldHub : hubSource.hubCellInHub) {
			this.NodeHubModificator(oldHub, newHub);
		}
		return true;
	}
}
