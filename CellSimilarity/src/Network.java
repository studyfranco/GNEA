import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

/**
 * Created by cholley on 16/01/17.
 * Created by Francois STUDER on 05/04/18.
 */


public class Network extends Container{

    boolean ajour = false;

    Set<Node> nodes = new HashSet<>();
    Set<Edge> edges = new HashSet<>();
    
    Set<Node> singleNodes = new HashSet<>();
    boolean ajourSingleNode = false;
    
    HashMap<Node, Integer> degree = new HashMap<>(); // Degree for the node in the network
    HashMap<Integer, LinkedList<Node>> degreeNodeMap = new HashMap<>(); // List of node by degree
    HashMap<Float, LinkedList<Edge>> correlationMap = new HashMap<>();
    HashMap<Edge, Float> edgesCorrelation = new HashMap<>(); // Map for see if the edge are present between two nodes, and store correlation if they have
    
    HashMap<Node,Boolean> DestinyHub = new HashMap<>(); // This one used the definition for a node become a hub or not
    HashMap<Node, LinkedList<Float>> nodeDifExp = new HashMap<>();
    HashMap<Node, Float> nodeYield = new HashMap<>();
    HashMap<Node, Double> nodePValYield = new HashMap<>();
    
    public Network() {
    	
    }
    
    public Network(File networkFile) {
    	this.nodes = new HashSet<>();
    	this.edges = new HashSet<>();
    	this.edgesCorrelation = new HashMap<>();
    	this.degree = new HashMap<>();
    	this.DestinyHub = new HashMap<>();
        
        try {
        	BufferedReader br = null;
            br = new BufferedReader(new FileReader(networkFile));
            String line = br.readLine();
            while ((line = br.readLine()) != null) {
            	String nodes [] = line.split("\t");
            	this.addEdge(nodes[0],nodes[1]);
            }
            br.close();
        } catch (IOException ex) {
            System.err.println(ex);
        }
                
        
        this.degreeUpdate();
        
        this.ajour = true;
        this.ajourSingleNode = true;
    }

    public boolean extractNetwork(File networkFile) {
        this.nodes = new HashSet<>();
        this.edges = new HashSet<>();
        this.edgesCorrelation = new HashMap<>();
        this.degree = new HashMap<>();
        this.DestinyHub = new HashMap<>();
        
        try {
        	BufferedReader br = null;
            br = new BufferedReader(new FileReader(networkFile));
            String line = br.readLine();
            while ((line = br.readLine()) != null) {
            	String nodes [] = line.split("\t");
            	this.addEdge(nodes[0],nodes[1]);
            }
            br.close();
        } catch (IOException ex) {
            System.err.println(ex);
            return false;
        }
        this.ajour = true;
        this.ajourSingleNode = true;
        this.degreeUpdate();
        return true;
    }
    
    public boolean extractNetworkfromMatrix(Matrix CellMat) {
    	this.nodes = new HashSet<>();
    	this.edges = new HashSet<>();
    	this.edgesCorrelation = new HashMap<>();
    	this.degree = new HashMap<>();
    	this.DestinyHub = new HashMap<>();
    	this.correlationMap = new HashMap<>();
        
        String correlation = null;
        HashMap<String, String> Cell = null;
        for (String rowName : CellMat.Case.keySet()) {
        	Cell = CellMat.Case.get(rowName);
        	for (String colName : Cell.keySet()) {
                	if (!rowName.equals(colName)) {
                    	correlation = Cell.get(colName);
                           if (!(correlation == null)) {
                        	   this.addEdge(rowName,colName,correlation);
                           } else {
                        	   this.addEdge(rowName,colName);
                           }
                	}
        	}
        }
        
        this.degreeUpdate();
        this.ajour = true;
        this.ajourSingleNode = true;
    	return true;
    }
    
    public Node addNode(String name) {
    	Node n = null;
        if (nodesMap.containsKey(name)) {
        	n = nodesMap.get(name);
        	if (!this.nodes.contains(n)) {
                this.nodes.add(n);
                this.singleNodes.add(n);
    	        this.degree.put(n, 0);
    	        this.DestinyHub.put(n, true);
    	        LinkedList<Float> difExp = new LinkedList<Float>();
                this.nodeDifExp.put(n, difExp);
        	}
        } else {
        	n = new Node(name);
            this.nodes.add(n);
            this.singleNodes.add(n);
	        this.degree.put(n, 0);
	        this.DestinyHub.put(n, true);
	        HashMap<Node, Edge> HashNode2 = new HashMap<>();
	        edgesMap.put(n, HashNode2);
	        Set<Edge> lT = new HashSet<Edge>();
        	nodeEdgesTargetMap.put(n, lT);
        	LinkedList<Float> difExp = new LinkedList<Float>();
            this.nodeDifExp.put(n, difExp);
        }
        return n;
    }

    public Node addNode(String name, double DifExp) {
        Node n = null;
        if (nodesMap.containsKey(name)) {
        	n = nodesMap.get(name);
        	if (!this.nodes.contains(n)) {
                this.nodes.add(n);
                this.singleNodes.add(n);
    	        this.degree.put(n, 0);
    	        this.DestinyHub.put(n, true);
    	        LinkedList<Float> difExp = new LinkedList<Float>();
                this.nodeDifExp.put(n, difExp);
        	}
        } else {
        	n = new Node(name);
            this.nodes.add(n);
            this.singleNodes.add(n);
	        this.degree.put(n, 0);
	        this.DestinyHub.put(n, true);
	        HashMap<Node, Edge> HashNode2 = new HashMap<>();
	        edgesMap.put(n, HashNode2);
	        Set<Edge> lT = new HashSet<Edge>();
        	nodeEdgesTargetMap.put(n, lT);
        	LinkedList<Float> difExp = new LinkedList<Float>();
            this.nodeDifExp.put(n, difExp);
        }
        return n;
    }
    
    public Node addNode(Node node) {
        Node n = null;
        if (nodesMap.containsKey(node.name)) {
        	n = nodesMap.get(node.name);
        	if (!this.nodes.contains(n)) {
                this.nodes.add(n);
                this.singleNodes.add(n);
    	        this.degree.put(n, 0);
    	        this.DestinyHub.put(n, true);
    	        LinkedList<Float> difExp = new LinkedList<Float>();
                this.nodeDifExp.put(n, difExp);
        	}
        } else {
        	n = node;
            this.nodes.add(n);
            this.singleNodes.add(n);
	        this.degree.put(n, 0);
	        this.DestinyHub.put(n, true);
	        HashMap<Node, Edge> HashNode2 = new HashMap<>();
	        edgesMap.put(n, HashNode2);
	        Set<Edge> lT = new HashSet<Edge>();
        	nodeEdgesTargetMap.put(n, lT);
        	LinkedList<Float> difExp = new LinkedList<Float>();
            this.nodeDifExp.put(n, difExp);
        }
        return n;
        
    }

    public Edge addEdge(Node node1, Node node2) {
    	Edge e = null;
    	Node Node1 = null;
    	Node Node2 = null;
    	HashMap<Node, Edge> HashNode2 = null;
    	float corr = 0f;
    	
    	Node1 = this.addNode(node1.name);
    	Node2 = this.addNode(node2.name);
    	
    	HashNode2 = edgesMap.get(Node1);
    	if (HashNode2.containsKey(Node2)) {
    		e = HashNode2.get(Node2);
    	} else {
    		e = new Edge(Node1, Node2);
    		HashNode2.put(Node2, e);
    	}
    	
        if (this.correlationMap.containsKey(corr)) {
        	LinkedList<Edge> eL = correlationMap.get(corr);
        	eL.add(e);
        } else {
        	LinkedList<Edge> eL = new LinkedList<>();
        	eL.add(e);
        	correlationMap.put(corr, eL);
        }
    	
        if (!this.edges.contains(e)) {
            this.edges.add(e);
            this.degree.put(Node1, degree.get(Node1)+1);
            this.degree.put(Node2, degree.get(Node2)+1);
            nodeEdgesTargetMap.get(Node2).add(e);
            edgesCorrelation.put(e, corr);
            this.singleNodes.remove(Node1);
            this.singleNodes.remove(Node2);
        }
        return e;
    }
    
    public Edge addEdge(String node1, String node2) {
    	Edge e = null;
    	Node Node1 = null;
    	Node Node2 = null;
    	HashMap<Node, Edge> HashNode2 = null;
    	float corr = 0f;
    	
    	Node1 = this.addNode(node1);
    	Node2 = this.addNode(node2);
    	
    	HashNode2 = edgesMap.get(Node1);
    	if (HashNode2.containsKey(Node2)) {
    		e = HashNode2.get(Node2);
    	} else {
    		e = new Edge(Node1, Node2);
    		HashNode2.put(Node2, e);
    	}
    	
        if (this.correlationMap.containsKey(corr)) {
        	LinkedList<Edge> eL = correlationMap.get(corr);
        	eL.add(e);
        } else {
        	LinkedList<Edge> eL = new LinkedList<>();
        	eL.add(e);
        	correlationMap.put(corr, eL);
        }
    	
        if (!this.edges.contains(e)) {
            this.edges.add(e);
            this.degree.put(Node1, degree.get(Node1)+1);
            this.degree.put(Node2, degree.get(Node2)+1);
            nodeEdgesTargetMap.get(Node2).add(e);
            this.edgesCorrelation.put(e, corr);
            this.singleNodes.remove(Node1);
            this.singleNodes.remove(Node2);
        }
        return e;
    }

    public Edge addEdge(String node1, String node2, String correlation) {
    	Edge e = null;
    	Node Node1 = null;
    	Node Node2 = null;
    	HashMap<Node, Edge> HashNode2 = null;
    	float corr = Float.parseFloat(correlation);
    	
    	Node1 = this.addNode(node1);
    	Node2 = this.addNode(node2);
    	
    	HashNode2 = edgesMap.get(Node1);
    	if (HashNode2.containsKey(Node2)) {
    		e = HashNode2.get(Node2);
    	} else {
    		e = new Edge(Node1, Node2);
    		HashNode2.put(Node2, e);
    	}
    	
        if (this.correlationMap.containsKey(corr)) {
        	LinkedList<Edge> eL = correlationMap.get(corr);
        	eL.add(e);
        } else {
        	LinkedList<Edge> eL = new LinkedList<>();
        	eL.add(e);
        	correlationMap.put(corr, eL);
        }
    	
        if (!this.edges.contains(e)) {
            this.edges.add(e);
            this.degree.put(Node1, degree.get(Node1)+1);
            this.degree.put(Node2, degree.get(Node2)+1);
            nodeEdgesTargetMap.get(Node2).add(e);
            this.edgesCorrelation.put(e, corr);
            this.singleNodes.remove(Node1);
            this.singleNodes.remove(Node2);
        }
        return e;
        
    }

    /**
     * Functions to load caracteristics of the network
     * @throws SQLException 
     */
    
    public boolean loadNodeInformations() throws SQLException {
    	loadNodeGoTerm();
    	loadNodeGRN();
    	loadNodeMRNetwork();
    	if (YieldFilesRep != null) {
        	loadNodeYield();
    	}
    	return true;
    }
    
    public boolean loadNodeGoTerm() throws SQLException {
        for (Node cell : this.nodes) {
    		File CellGOFile = new File(GoFilesRep.getAbsolutePath() + File.separator + debutFileGO +
                	cell.name + ".tsv");
    		cell.GONode(CellGOFile);
    	}
        GOTerm.treeGenerator();
        return true;
    }
    
    public boolean loadNodeGRN() {
        for (Node cell : this.nodes) {
    		File CellGRNFile = new File(GRNFilesRep.getAbsolutePath() + File.separator + debutFileGRN +
                	cell.name + ".tsv");
    		cell.GRNLoad(CellGRNFile);
    	}
        return true;
    }
    
    public boolean loadNodeMRNetwork() {
        for (Node cell : this.nodes) {
    		File CellMRNetworkFile = new File(MRNetworkFilesRep.getAbsolutePath() + File.separator + debutFileMRNetwork +
                	cell.name + ".tsv");
    		cell.MRLoad(CellMRNetworkFile);
    	}
        return true;
    }
    
    public boolean loadNodeYield() {
        for (Node cell : this.nodes) {
    		File CellYieldFile = new File(YieldFilesRep.getAbsolutePath() + File.separator + debutFileYield +
                	cell.name + ".tsv");
    		cell.MRNet.loadNodeAttributYield(CellYieldFile);
    		cell.GRN.loadNodeAttributYield(CellYieldFile);
    	}
        return true;
    }
    
    public boolean loadNodeAttributYield(File YieldFile) {
    	try {
    		BufferedReader br = null;
    		br = new BufferedReader(new FileReader(YieldFile));
    		String line = br.readLine();
            while ((line = br.readLine()) != null) {
            	String Yield [] = line.split("\t");
            	this.nodeYield.put(this.addNode(Yield[0]),Float.parseFloat(Yield[1]));
            	this.nodePValYield.put(this.addNode(Yield[0]),Double.parseDouble(Yield[2]));
            }
    		br.close();
    	} catch (IOException ex) {
            System.err.println(ex);
            return false;
        }
    	return true;
    }
    
    public boolean loadNodeDiffExp(File DiffGeneFile) {
    	try {
    		BufferedReader br = null;
    		br = new BufferedReader(new FileReader(DiffGeneFile));
    		
    		br.close();
    	} catch (IOException ex) {
            System.err.println(ex);
            return false;
        }
    	return true;
    }
    
    /**
     * Functions to update caracteristics of the network
     */
    
    public boolean singleNodeDetector() {
    	Set<Edge> Possibility = null;
    	this.singleNodes = new HashSet<>();
    	for (Node node : nodes) {
    		Possibility = new HashSet<>();
    		Possibility.addAll(edgesMap.get(node).values());
    		Possibility.addAll(nodeEdgesTargetMap.get(node));
    		Possibility.retainAll(this.edges);
    		if (Possibility.size() == 0) {
    			this.singleNodes.add(node);
    		}
    	}
    	this.ajourSingleNode = true;
    	return true;
    }
    
    public boolean degreeUpdate() {
        int deg = 0;
        for (Node n : this.nodes) {
        	deg = getDegreeNode(n);
            if (this.degreeNodeMap.containsKey(deg)) {
            	LinkedList<Node> l = this.degreeNodeMap.get(deg);
            	l.add(n);
            } else {
            	LinkedList<Node> l = new LinkedList<>();
            	l.add(n);
            	this.degreeNodeMap.put(deg, l);
            }
        }
    	return true;
    }
    
    public boolean NodesdegreeUpdate() {
    	this.degree = new HashMap<>();
    	for (Node n : nodes) {
    		this.degree.put(n, 0);
    	}
    	for (Edge e : edges) {
    		this.degree.put(e.nodeSource, degree.get(e.nodeSource)+1);
            this.degree.put(e.nodeTarget, degree.get(e.nodeTarget)+1);
    	}
    	this.degreeUpdate();
    	return true;
    }
    
    /**
     *  Functions to get information about network or network
     */
    
    public Network clone() {
    	Network clone = new Network();
    	clone.nodes.addAll(this.nodes);
    	clone.edges.addAll(this.edges);
    	clone.singleNodes.addAll(this.singleNodes);
    	clone.degree.putAll(this.degree);
    	clone.degreeNodeMap.putAll(this.degreeNodeMap);
    	clone.correlationMap.putAll(this.correlationMap);
    	clone.edgesCorrelation.putAll(this.edgesCorrelation);
    	clone.DestinyHub.putAll(this.DestinyHub);
    	clone.nodeDifExp.putAll(this.nodeDifExp);
    	clone.nodeYield.putAll(this.nodeYield);
    	clone.nodePValYield.putAll(this.nodePValYield);
    	//clone.degreeUpdate();
    	return clone;
    }
    
    public List<Edge> getAdjacentEdgeList(final Node n, int regulation_type) {
        if (!nodeDifExp.containsKey(n))
            return Collections.emptyList();

        List<Edge> ret = new ArrayList<>();
        for (Edge edge : edges) {
            if (edge.nodeSource == n || edge.nodeTarget == n) {
                if (regulation_type == REGULATION_POSITIVE) {
                    if (edge.nodeSource == n) {
                        if ((double) nodeDifExp.get(edge.nodeTarget).get(0) > 0) {
                            ret.add(edge);
                        }
                    }
                } else if (regulation_type == REGULATION_NEGATIVE) {
                    if (edge.nodeSource == n) {
                        if ((double) nodeDifExp.get(edge.nodeTarget).get(0) < 0) {
                            ret.add(edge);
                        }
                    }
                } else {
                    ret.add(edge);
                }
            }
        }

        return ret;
    }
    
    public List<Edge> getConnection(HashSet<Node> nodeList) {
    	List<Edge> edgeList = new LinkedList<>();
    	HashMap<Node, Edge> MapSource = null;
    	// List<Edge> edgeParcours
		for (Node nodeSource : nodeList) {
			MapSource = edgesMap.get(nodeSource);
			for (Node nodeTarget : nodeList) {
				if (MapSource.containsKey(nodeTarget)) {
					edgeList.add(MapSource.get(nodeTarget));
				}
			}
			//for (Edge e : nodeEdgesMap.get(node))
	    	//	if (nodeList.contains(e.nodeTarget)) {
	    	//		edgeList.add(e);
	    	//	}
		}
		edgeList.retainAll(edges);
    	return edgeList;
    }
    
    public LinkedList<Node> getListConnexInduce(Node Hub) {
    	LinkedList<Node> connex = new LinkedList<>();
    	Set<Edge> KeyEdges = new HashSet<Edge>(edgesMap.get(Hub).values());
    	for (Edge e : KeyEdges) {
    		connex.add(e.nodeTarget);
    	}
    	return connex;
    }

    public int getNodeCount() {
        return nodes.size();
    }

    public int getEdgeCount() {
        return edges.size();
    }

    public int getDegreeNode(Node node) {
    	return degree.get(node);
    }
     
    public LinkedList<Edge> getEdgesIn(float similarityMax, float similarityMin){
    	LinkedList<Edge> edgeGood = new LinkedList<>(); 
    	
    	List<Float> keys = new ArrayList<Float>(correlationMap.keySet());
    	Collections.sort(keys, Collections.reverseOrder());
    	
    	for(Float corr : keys) {
    		if (corr >= similarityMax) {
    			continue;
    		} else if (corr >= similarityMin) {
            	edgeGood.addAll(correlationMap.get(corr));
    		} else {
    			break;
    		}
    	}
    	
    	return edgeGood;
    }
    
    public Network getPartOf(List<Node> Nodes) {
    	List<Edge> selectEdges = new ArrayList<>();
    	for (Node SourceNode : Nodes) {
        	for (Node TargetNode : Nodes) {
        		selectEdges.add(edgesMap.get(SourceNode).get(TargetNode));
        	}
    	}
    	Network Little = new Network();
    	Little.nodes.addAll(Nodes);
    	Little.edges.addAll(this.edges);
    	Little.edges.retainAll(selectEdges);
    	Little.correlationMap.putAll(this.correlationMap);
    	Little.edgesCorrelation.putAll(this.edgesCorrelation);
    	Little.DestinyHub.putAll(this.DestinyHub);
    	Little.nodeDifExp.putAll(this.nodeDifExp);
    	Little.nodeYield.putAll(this.nodeYield);
    	Little.nodePValYield.putAll(this.nodePValYield);
    	Little.NodesdegreeUpdate();
    	Little.singleNodeDetector();
    	
    	return Little;
    }
    
    public Network getCommon(Network otherNetwork) {
    	Network Little = new Network();
    	Little.nodes.addAll(this.nodes);
    	Little.nodes.retainAll(otherNetwork.nodes);
    	Little.edges.addAll(this.edges);
    	Little.edges.retainAll(otherNetwork.edges);
    	
    	Little.nodeYield.putAll(this.nodeYield);
    	Little.nodeYield.forEach((k, v) -> this.nodeYield.merge(k, v, (v1, v2) -> v1 + v2));
    	Little.nodePValYield.putAll(this.nodePValYield);
    	Little.nodePValYield.forEach((k, v) -> this.nodePValYield.merge(k, v, (v1, v2) -> v1 + v2));
    	
    	// Little.NodesdegreeUpdate();
    	// Little.singleNodeDetector();
    	
    	// Exchange with the precedent line. You need really to update degree and single node
    	Little.degree.putAll(this.degree);
    	Little.degreeNodeMap.putAll(this.degreeNodeMap);
    	Little.degree.putAll(otherNetwork.degree);
    	Little.degreeNodeMap.putAll(otherNetwork.degreeNodeMap);
    	
    	// To Improve for create a mean
    	Little.correlationMap.putAll(this.correlationMap);
    	Little.edgesCorrelation.putAll(this.edgesCorrelation);
    	Little.DestinyHub.putAll(this.DestinyHub);
    	Little.nodeDifExp.putAll(this.nodeDifExp);
    	
    	return Little;
    }
    
    /**
     * Functions to fusion this network with another
     */
    
    public void addNetwork(Network newNetwork) {
    	// We add each new edges in the network
    	if (newNetwork != null) {
        	for (Edge NewEdges : newNetwork.edges) {
        		this.addEdge(NewEdges.nodeSource,NewEdges.nodeTarget);
        	}
	    	this.nodes.addAll(newNetwork.nodes);
        	this.edgesCorrelation.putAll(newNetwork.edgesCorrelation);
	    	this.nodeYield.putAll(newNetwork.nodeYield);
	    	this.nodePValYield.putAll(newNetwork.nodePValYield);	
    	} else {
    		System.out.println("Warning ! You have bad network adding. It may be caused fail your expertise !");
    	}

    }
    
    public void fusionNetwork(Network newNetwork) {
    	// We add each new edges in the network
    	if (newNetwork != null) {
    	    	this.nodes.addAll(newNetwork.nodes);
    	    	this.edges.addAll(newNetwork.edges);
    	    	
    			newNetwork.edgesCorrelation.forEach((k, v) -> this.edgesCorrelation.merge(k, v, (v1, v2) -> v1 + v2));
    			newNetwork.nodeYield.forEach((k, v) -> this.nodeYield.merge(k, v, (v1, v2) -> v1 + v2));
    			newNetwork.nodePValYield.forEach((k, v) -> this.nodePValYield.merge(k, v, (v1, v2) -> v1 + v2));
    			
    			// To Improve for create a mean
    			this.DestinyHub.putAll(newNetwork.DestinyHub);
    			this.nodeDifExp.putAll(newNetwork.nodeDifExp);
    	} else {
    		System.out.println("Warning ! You have bad network adding. It may be caused fail your expertise !");
    	}

    }
    
    /**
     * Functions to write information about the network
     */
    
    public void writeNetwork(File networkFile) {
        try {
	        BufferedWriter bw = null;
	        bw = new BufferedWriter(new FileWriter(networkFile));
        
	        bw.write("TF" + "\t" + "TG" + "\n");
	        
	        for (Edge edge : this.edges) {
	            bw.write(edge.nodeSource.name + "\t" + edge.nodeTarget.name + "\n");
	        }
	        for (Node node : this.singleNodes) {
	        	bw.write(node.name + "\t" + node.name + "\n");
	        }
	        bw.flush();
			bw.close();
        
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
    
    public void writeNodeDegree(File degreeFile) {
        try {
            BufferedWriter bw = null;
            bw = new BufferedWriter(new FileWriter(degreeFile, false)); //second parameter is "append"
            bw.write("Node" + "\t" + "degree" + "\n");
            List<Integer> sortedList = new ArrayList<Integer>(this.degreeNodeMap.keySet());
            Collections.reverse(sortedList);
            for (int degre : sortedList) {
            	LinkedList<Node> l = this.degreeNodeMap.get(degre);
            	for (int is=0; is<l.size(); is++) {
    	            bw.write(l.get(is).name + "\t" + this.getDegreeNode(l.get(is)) + "\n");
            	}
            }
            bw.flush();
            bw.close();
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}