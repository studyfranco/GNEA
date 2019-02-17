/**
 * Created by cholley on 16/01/17.
 * Modified by Francois STUDER on 05/04/18.
 */

class Edge extends Container{
    int UUID;
    private static int GUUID = 0;
    Node nodeSource;
    Node nodeTarget;

    public Edge(Node nodeSource, Node nodeTarget) {
        UUID = GUUID++;
        this.nodeSource = nodeSource;
        this.nodeTarget = nodeTarget;
    }

    @Override
    public String toString() {
        return nodeSource.name + " -> " + nodeTarget.name;
    }
}
