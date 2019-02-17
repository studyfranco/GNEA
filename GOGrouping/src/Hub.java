import java.util.HashMap;
import java.util.LinkedHashSet;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class Hub extends Node{
	
    public HashMap<GOTerm, Integer> NetworkPresence = new HashMap<>();
	// this.NetworkPresence= new HashMap<>(N.NetworkPresence);
    // newNode.NetworkPresence= new HashMap<>(this.NetworkPresence);
	public Hub(Node N) {
		// TODO Auto-generated constructor stub
		super(N);
		
	}
	
	public boolean GOCommon(Node N) {
		this.GOTerm.retainAll(N.GOTerm);
    	// this.GOTerm.addAll(N.GOTerm);
		// hs.addAll(al);
		// al.clear();
		// al.addAll(hs);
    	// Set<GOTerm> linkedHashSet = new LinkedHashSet<>();
    	return true;
    }
	
    public boolean GOConnectivite(Node N) {
    	for(GOTerm Term : N.GOTerm) {
    		if(NetworkPresence.containsKey(Term)) {
    			this.NetworkPresence.put(Term,NetworkPresence.get(Term)+1);
    		} else {
    			this.NetworkPresence.put(Term,1);
    		}
    	}
    	return true;
    }

}
