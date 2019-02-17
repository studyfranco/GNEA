import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class GOExtractor extends Container{
	
	Network Net = null;
	Matrix GOMat = new Matrix();
	File MatrixFileChild = new File(GOCell_Folder.getAbsolutePath() + File.separator + "GOChildMatrix" + ".tsv");
	File MatrixFile = new File(GOCell_Folder.getAbsolutePath() + File.separator + "GOMatrix" + ".tsv");
	
	public boolean ExtarctGOTermNodes() {
		GOTermMapChild = new HashSet<>();
		File netHub = null;
		if (WriteGOTermNode) {
			netHub = new File(GOCell_Folder.getAbsolutePath() + File.separator + GONetFolderName);
			netHub.mkdir();
			netHub = new File(GOCell_Folder.getAbsolutePath() + File.separator + GOAttFolderName);
			netHub.mkdir();
		}
        for (Node cell : Net.nodes) {
        	cell.CleanGO();
        	if (WriteGOTermNode) {
            	cell.GONetCreate();
            	cell.SaveGoNet(GOCell_Folder);
            	cell.GONet = null;
        	}
    	}
        
/**        bw = new BufferedWriter(new FileWriter(NumberGOFile, false)); //second parameter is "append"
        bw.write("Node" + "\t" + "Number GO Term"+ "\t"+ "Number Child" + "\n");
        for (int ir=0; ir<task.HubList.size(); ir++) {
        	bw.write(task.HubList.get(ir).name + "\t" + task.HubList.get(ir).GOTerms.size()+ "\t" + task.HubList.get(ir).GOTermClean.size() + "\n");
        }
        bw.flush();
        bw.close();
        
        
    } catch (IOException e) {
        e.printStackTrace();
        System.exit(1);
    } **/
        
        List<GOTerm> keys = new ArrayList<>(GOTermMapChild);
        for (Node cell : Net.nodes) {
        	for (int is=0; is<keys.size(); is++) {
        		if (cell.GOTermPvalue.get(keys.get(is)) != null) {
        			GOMat.insertValue(cell.name, keys.get(is).Term, cell.GOTermPvalue.get(keys.get(is)).toString());
        		}
        	}
        }
        GOMat.writeMatrix(MatrixFileChild);
        GOMat = new Matrix();
        keys = new ArrayList<>(GOTermMapGood);
        for (Node cell : Net.nodes) {
        	for (int is=0; is<keys.size(); is++) {
        		if (cell.GOTermPvalue.get(keys.get(is)) != null) {
        			GOMat.insertValue(cell.name, keys.get(is).Term, cell.GOTermPvalue.get(keys.get(is)).toString());
        		}
        	}
        }
        GOMat.writeMatrix(MatrixFile);
        
        return true;
	}
}
