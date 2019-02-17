/**
 * Created by cholley on 16/01/17.
 * Modified by Francois STUDER on 04/05/2018
 */

class Edge extends Container{
    Node nodeSource;
    Node nodeTarget;

    public Edge(Node nodeSource, Node nodeTarget) {
        this.nodeSource = nodeSource;
        this.nodeTarget = nodeTarget;
    }

    @Override
    public String toString() {
        return nodeSource.name + " -> " + nodeTarget.name;
    }
}
