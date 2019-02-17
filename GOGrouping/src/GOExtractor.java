import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class GOExtractor extends Container{
	
	File GoFilesRep = null;
	Network Net = null;
	Matrix GOMat = new Matrix();
	LinkedList<Hub> HubList = new LinkedList<>();
	LinkedList<Node> connex = new LinkedList<>();
	HashMap<Node, Boolean> NodeExclu = new HashMap<>();
	File degreeFile = new File(result_rep.getAbsolutePath() + File.separator + "degree" + ".tsv");
	File MatrixFileChild = new File(result_rep.getAbsolutePath() + File.separator + "GOChildMatrix" + ".tsv");
	File MatrixFile = new File(result_rep.getAbsolutePath() + File.separator + "GOMatrix" + ".tsv");
	
	public boolean HubAllNode() throws SQLException {
		
        for (int it=0; it<(Net.degreeNodeMap.size()); it++) {
        	LinkedList<Node> l = Net.degreeNodeMap.get(Net.degreeArray[it]);
        	for (int is=0; is<l.size(); is++) {
        		Node Hub = l.get(is);
        		if(!Hub.GOComp) {
        			File HubGOFile = new File(GoFilesRep.getAbsolutePath() + File.separator + debutFileGO +
                    	Hub.name + ".tsv");
            		Hub.GONode(HubGOFile);
        		}
        		connex = Net.getListConnex(Hub);
        		Hub HubComplet = new Hub(Hub);
        		/** for (int ir=0; ir<connex.size(); ir++) {
            		Node N = connex.get(ir);
            		if(!N.GOComp) {
                		File NGOFile = new File(GoFilesRep.getAbsolutePath() + File.separator + "GOTerm_regulom_TG.Lfc1." +
                        		N.name + ".tsv");
                		N.GONode(NGOFile);
            		}
            		HubComplet.GOConnectivite(N);
            		HubComplet.GOCommon(N);
        		}**/
        		HubList.add(HubComplet); 
        	}
        }
        GOTerm.treeGenerator();
        for (int it=0; it<HubList.size(); it++) {
        	HubList.get(it).GONetCreate();
        	HubList.get(it).CleanGO();
        	HubList.get(it).SaveGoNet();
        	HubList.get(it).GONet = null;
        }
        Double pval = new Double(0);
        List<GOTerm> keys = new ArrayList<>(Node.GOTermMapChild.keySet());
        for (int it=0; it<HubList.size(); it++) {
        	for (int is=0; is<keys.size(); is++) {
        		if (HubList.get(it).GOTermPvalue.get(keys.get(is)) != null) {
        			pval = (double) HubList.get(it).GOTermPvalue.get(keys.get(is));
        			pval = -10*Math.log10(pval);
            		GOMat.insertValue(HubList.get(it).name, keys.get(is).Term, pval.toString());
        		}
        	}
        }
        Net.writeNodeDegree(degreeFile);
        GOMat.writeMatrix(MatrixFileChild);
        GOMat = new Matrix();
        keys = new ArrayList<>(Node.GOTermMapGood.keySet());
        for (int it=0; it<HubList.size(); it++) {
        	for (int is=0; is<keys.size(); is++) {
        		if (HubList.get(it).GOTermPvalue.get(keys.get(is)) != null) {
        			pval = (double) HubList.get(it).GOTermPvalue.get(keys.get(is));
        			pval = -10*Math.log10(pval);
            		GOMat.insertValue(HubList.get(it).name, keys.get(is).Term, pval.toString());
        		}
        	}
        }
        GOMat.writeMatrix(MatrixFile);
        
        return true;
	}
}
