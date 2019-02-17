import java.sql.SQLException;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class Main {

	public static void main(String[] args) throws SQLException {
		// TODO Auto-generated method stub
		
		ArgParser.parse(args); // Load Arguments
		Container.result_rep.mkdir();
		
		System.out.println("Loading Matrix");
		Matrix matCellSimil = new Matrix();
		matCellSimil.LectureMatCarre(Container.cellMatrixFile);
		System.out.println("Loading Matrix Complete");
		
		System.out.println("Creating network");
		Network netCell = new Network();
		if(!netCell.extractNetworkfromMatrix(matCellSimil)) {
			System.err.println("Error with the matrix file, they aren't load correctly");
            System.exit(1);
		}
		System.out.println("Loading Cells informations");
		matCellSimil = null;
		System.gc();
		netCell.loadNodeInformations();
		System.out.println("Loading Complete");
		
		if (Container.ExtractGOTermNode) {
			System.out.println("Compute GO term. Search Childs");
			Container.GOCell_Folder.mkdir();
			GOExtractor task = new GOExtractor();
			task.Net = netCell;
			task.ExtarctGOTermNodes();
			task = null;
			System.gc();
			System.out.println("All GO Term Child Fonds for all Nodes");
		}
		
		if (Container.TopologyCompute) {
			System.out.println("Compute topology on matrix");
			Container.topologyFolder.mkdir();
			NetTopology task = new NetTopology();
			task.CellNetwork = netCell;
			task.topologyCreator();
			task.writeTopology();
			System.out.println("Topology task finish");
		}
			    
        System.exit(0);
	}

}
