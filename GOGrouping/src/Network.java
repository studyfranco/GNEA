import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

/**
 * Created by cholley on 16/01/17.
 * Modified by Francois STUDER on 05/04/18.
 */
public class Network extends Container{

    static int REGULATION_POSITIVE = 1;
    static int REGULATION_NEGATIVE = 2;
    static int ALL_REGULATION = 0;
    boolean ajour = false;

    LinkedList<Node> nodes = new LinkedList<>();
    LinkedList<Edge> edges = new LinkedList<>();
    
    List<Node> singleNodes = new ArrayList<>();
    
    HashMap<Integer, Object[]> nodeAttributs = new HashMap<>();
    HashMap<Integer, Object[]> edgeAttributs = new HashMap<>();
    
    HashMap<Node, Integer> degree = new HashMap<>(); // Degree for the node in the network
    HashMap<Integer, LinkedList<Node>> degreeNodeMap = new HashMap<>(); // List of node by degree
    Integer[] degreeArray = null; // List of degree in the network
    
    HashMap<Node, LinkedList<Edge>> nodeEdgesMap = new HashMap<>(); // List edges for the nodes in the network
    HashMap<Node, HashMap<Node, Boolean>> edgesPresent = new HashMap<>(); // Map for see if the edge are present between two nodes
    
    HashMap<Node,Boolean> DestinyHub = new HashMap<>(); // This one used the definition for a node become a hub or not
    
    public Network() {
    	
    }
    
    public Network(File networkFile) {
        nodes = new LinkedList<>();
        edges = new LinkedList<>();
        nodesMap = new HashMap<>();
        nodeAttributs = new HashMap<>();
        edgeAttributs = new HashMap<>();
        nodeEdgesMap = new HashMap<>();
        edgesPresent = new HashMap<>();
        degree = new HashMap<>();
        DestinyHub = new HashMap<>();
        
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
                
        
        int deg = 0;
        
        
        for (int it=0; it<nodes.size(); it++) {
        	deg = getDegreeNode(nodes.get(it));
            if (degreeNodeMap.containsKey(deg)) {
            	LinkedList<Node> l = degreeNodeMap.get(deg);
            	l.add(nodes.get(it));
            } else {
            	LinkedList<Node> l = new LinkedList<>();
            	l.add(nodes.get(it));
            	degreeNodeMap.put(deg, l);
            }
        	
        }
        
        Set<Integer> keys = degreeNodeMap.keySet();
        degreeArray = keys.toArray(new Integer[keys.size()]);
        Arrays.sort(degreeArray, Collections.reverseOrder());
    }
    
    public Node addNode(String name) {
    	Node n = null;
        if (nodesMap.containsKey(name)) {
        	n = nodesMap.get(name);
        	if (nodeAttributs.containsKey(n.UUID)){
                System.err.println("duplicate node in network: " + name);
                System.exit(1);
            }
        } else {
        	n = new Node(name);
        }
        nodes.add(n);
        nodeAttributs.put(n.UUID, new String[]{name});
        singleNodes.add(n);
        return n;
    }

    public Node addNode(String name, double DifExp) {
    	Node n = null;
        if (nodesMap.containsKey(name)) {
        	n = nodesMap.get(name);
        	if (nodeAttributs.containsKey(n.UUID)){
                System.err.println("duplicate node in network: " + name);
                System.exit(1);
            }
        } else {
        	n = new Node(name);
        }
        nodes.add(n);
        nodeAttributs.put(n.UUID, new Object[]{name, DifExp});
        singleNodes.add(n);
        return n;
    }
    
    public Node addNode(Node node) {
        Node n = node;
    	if (nodeAttributs.containsKey(n.UUID)){
            System.err.println("duplicate node in network: " + n.name);
            System.exit(1);
        }
        nodes.add(n);
        nodeAttributs.put(n.UUID, new String[]{node.name});
        singleNodes.add(n);
        return n;
    }

    public Edge addEdge(Node node1, Node node2) {
    	Edge e = null;
    	Node Node1 = null;
    	Node Node2 = null;
    	HashMap<Node, Boolean> l1 = null;
    	HashMap<Node, Boolean> l2 = null;
    	LinkedList<Edge> l = null;
    	HashMap<Node, Edge> HashNode2 = null;
    	if (nodesMap.containsKey(node1.name)) {
    		Node1 = nodesMap.get(node1.name);
    		if (!this.degree.containsKey(Node1)) {
    	        nodes.add(Node1);
    	        nodeAttributs.put(Node1.UUID, new String[]{Node1.name});
    	        this.degree.put(Node1, 0);
    	        DestinyHub.put(Node1, true);
    	        
    	        l1 = new HashMap<>();
    	        edgesPresent.put(Node1, l1);
            	l = new LinkedList<>();
            	nodeEdgesMap.put(Node1, l);
    		} else {
    			l1 = edgesPresent.get(Node1);
    			l = nodeEdgesMap.get(Node1);
    		}
    	} else {
    		Node1 = this.addNode(node1);
    		l1 = new HashMap<>();
    		edgesPresent.put(Node1, l1);
        	l = new LinkedList<>();
        	nodeEdgesMap.put(Node1, l);
	        this.degree.put(Node1, 0);
	        DestinyHub.put(Node1, true);
    	}
    	
    	if (nodesMap.containsKey(node2.name)) {
    		Node2 = nodesMap.get(node2.name);
    		if (!this.degree.containsKey(Node2)) {
    	        nodes.add(Node2);
    	        nodeAttributs.put(Node2.UUID, new String[]{Node2.name});
    	        this.degree.put(Node2, 0);
    	        DestinyHub.put(Node2, true);
    	        
    	        l2 = new HashMap<>();
    	        edgesPresent.put(Node2, l2);
            	l = new LinkedList<>();
            	nodeEdgesMap.put(Node2, l);
    		} else {
    			l2 = edgesPresent.get(Node2);
    		}
    	} else {
    		Node2 = this.addNode(node2);
    		l2 = new HashMap<>();
    		edgesPresent.put(Node2, l2);
        	l = new LinkedList<>();
        	nodeEdgesMap.put(Node2, l);
	        this.degree.put(Node2, 0);
	        DestinyHub.put(Node2, true);
    	}
    	
    	if (edgesMap.containsKey(Node1)) {
    		HashNode2 = edgesMap.get(Node1);
    		if (HashNode2.containsKey(Node2)) {
    			e = HashNode2.get(Node2);
    		} else {
    			e = new Edge(Node1, Node2);
    			HashNode2.put(Node2, e);
    		}
    	} else {
    		e = new Edge(Node1, Node2);
    		HashNode2 = new HashMap<>();
    		HashNode2.put(Node2, e);
    		edgesMap.put(Node1, HashNode2);
    	}
    	
        this.edges.add(e);
        this.edgeAttributs.put(e.UUID, new Object[]{Node1.name, Node2.name});
        this.degree.put(Node1, degree.get(Node1)+1);
        this.degree.put(Node2, degree.get(Node2)+1);
        
        l = nodeEdgesMap.get(Node1);
        l.add(e);
        l1.put(Node2,true);
        l2.put(Node1,true);
        singleNodes.remove(Node1);
        singleNodes.remove(Node2);
        return e;
    }
    
    public Edge addEdge(String node1, String node2) {
    	Edge e = null;
    	Node Node1 = null;
    	Node Node2 = null;
    	HashMap<Node, Boolean> l1 = null;
    	HashMap<Node, Boolean> l2 = null;
    	LinkedList<Edge> l = null;
    	HashMap<Node, Edge> HashNode2 = null;
    	if (nodesMap.containsKey(node1)) {
    		Node1 = nodesMap.get(node1);
    		if (!this.degree.containsKey(Node1)) {
    	        nodes.add(Node1);
    	        nodeAttributs.put(Node1.UUID, new String[]{Node1.name});
    	        this.degree.put(Node1, 0);
    	        DestinyHub.put(Node1, true);
    	        
    	        l1 = new HashMap<>();
    	        edgesPresent.put(Node1, l1);
            	l = new LinkedList<>();
            	nodeEdgesMap.put(Node1, l);
    		} else {
    			l1 = edgesPresent.get(Node1);
    			l = nodeEdgesMap.get(Node1);
    		}
    	} else {
    		Node1 = this.addNode(node1);
    		l1 = new HashMap<>();
    		edgesPresent.put(Node1, l1);
        	l = new LinkedList<>();
        	nodeEdgesMap.put(Node1, l);
	        this.degree.put(Node1, 0);
	        DestinyHub.put(Node1, true);
    	}
    	
    	if (nodesMap.containsKey(node2)) {
    		Node2 = nodesMap.get(node2);
    		if (!this.degree.containsKey(Node2)) {
    	        nodes.add(Node2);
    	        nodeAttributs.put(Node2.UUID, new String[]{Node2.name});
    	        this.degree.put(Node2, 0);
    	        DestinyHub.put(Node2, true);
    	        
    	        l2 = new HashMap<>();
    	        edgesPresent.put(Node2, l2);
            	l = new LinkedList<>();
            	nodeEdgesMap.put(Node2, l);
    		} else {
    			l2 = edgesPresent.get(Node2);
    		}
    	} else {
    		Node2 = this.addNode(node2);
    		l2 = new HashMap<>();
    		edgesPresent.put(Node2, l2);
        	l = new LinkedList<>();
        	nodeEdgesMap.put(Node2, l);
	        this.degree.put(Node2, 0);
	        DestinyHub.put(Node2, true);
    	}
    	
    	if (edgesMap.containsKey(Node1)) {
    		HashNode2 = edgesMap.get(Node1);
    		if (HashNode2.containsKey(Node2)) {
    			e = HashNode2.get(Node2);
    		} else {
    			e = new Edge(Node1, Node2);
    			HashNode2.put(Node2, e);
    		}
    	} else {
    		e = new Edge(Node1, Node2);
    		HashNode2 = new HashMap<>();
    		HashNode2.put(Node2, e);
    		edgesMap.put(Node1, HashNode2);
    	}
    	
        this.edges.add(e);
        this.edgeAttributs.put(e.UUID, new Object[]{Node1.name, Node2.name});
        this.degree.put(Node1, degree.get(Node1)+1);
        this.degree.put(Node2, degree.get(Node2)+1);
        
        l = nodeEdgesMap.get(Node1);
        l.add(e);
        l1.put(Node2,true);
        l2.put(Node1,true);
        singleNodes.remove(Node1);
        singleNodes.remove(Node2);
        return e;
    }

    public List<Edge> getAdjacentEdgeList(final Node n, int regulation_type) {
        if (!nodeAttributs.containsKey(n.UUID))
            return Collections.emptyList();

        List<Edge> ret = new ArrayList<>();
        for (Edge edge : edges) {
            if (edge.nodeSource.UUID == n.UUID || edge.nodeTarget.UUID == n.UUID) {
                if (regulation_type == REGULATION_POSITIVE) {
                    if (edge.nodeSource.UUID == n.UUID) {
                        if ((double) nodeAttributs.get(edge.nodeTarget.UUID)[1] > 0) {
                            ret.add(edge);
                        }
                    }
                } else if (regulation_type == REGULATION_NEGATIVE) {
                    if (edge.nodeSource.UUID == n.UUID) {
                        if ((double) nodeAttributs.get(edge.nodeTarget.UUID)[1] < 0) {
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
    
    public LinkedList<Edge> getConnection(HashSet<Node> nodeList) {
    	LinkedList<Edge> edgeList = new LinkedList<>();
		for (Node node : nodeList) {
			for (Edge e : nodeEdgesMap.get(node))
	    		if (nodeList.contains(e.nodeTarget)) {
	    			edgeList.add(e);
	    		}
		}
    	return edgeList;
    }

    public int getNodeCount() {
        return nodes.size();
    }

    public int getEdgeCount() {
        return edges.size();
    }

    public boolean extractNetwork(File networkFile) {
    	
        nodes = new LinkedList<>();
        edges = new LinkedList<>();
        nodesMap = new HashMap<>();
        nodeAttributs = new HashMap<>();
        edgeAttributs = new HashMap<>();
        nodeEdgesMap = new HashMap<>();
        edgesPresent = new HashMap<>();
        degree = new HashMap<>();
        DestinyHub = new HashMap<>();
        
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
                
        
        int deg = 0;
        
        
        for (int it=0; it<nodes.size(); it++) {
        	deg = getDegreeNode(nodes.get(it));
            if (degreeNodeMap.containsKey(deg)) {
            	LinkedList<Node> l = degreeNodeMap.get(deg);
            	l.add(nodes.get(it));
            } else {
            	LinkedList<Node> l = new LinkedList<>();
            	l.add(nodes.get(it));
            	degreeNodeMap.put(deg, l);
            }
        	
        }
        
        Set<Integer> keys = degreeNodeMap.keySet();
        degreeArray = keys.toArray(new Integer[keys.size()]);
        Arrays.sort(degreeArray, Collections.reverseOrder());
        
        return true;
    }
    
    public int getDegreeNode(Node node) {
    	return degree.get(node);
    }
    
    public LinkedList<Node> getListConnex(Node Hub) {
    	LinkedList<Node> connex = null;
    	Set<Node> KeyNodes = edgesPresent.get(Hub).keySet();
    	Node[] NodesArray = KeyNodes.toArray(new Node[KeyNodes.size()]);
    	connex = new LinkedList<>(Arrays.asList(NodesArray));
    	return connex;
    }

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
            for (int it=0; it<this.degreeNodeMap.size(); it++) {
            	LinkedList<Node> l = this.degreeNodeMap.get(this.degreeArray[it]);
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