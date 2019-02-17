import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * @author Francois STUDER
 * Created by Francois STUDER on 05/04/18.
 **/

public class Matrix {
	
	public List<String> RowNames = new ArrayList<String>();
	public List<String> ColNames = new ArrayList<String>();
	HashMap<String, Boolean> Col = new HashMap<>();
	HashMap<String, HashMap<String, String>> Case = new HashMap<>();
	
	public Matrix(){
		
	}
	
	public boolean insertValue (String RowName, String ColNames, String Value) {
		if (this.Case.containsKey(RowName)) {
			HashMap<String, String> Row = Case.get(RowName);
			if (!this.Col.containsKey(ColNames)) {
				this.ColNames.add(ColNames);
				this.Col.put(ColNames, true);
			}
			Row.put(ColNames, Value);
		} else {
			HashMap<String, String> Row = new HashMap<>();
			this.RowNames.add(RowName);
			Row.put(ColNames, Value);
			Case.put(RowName, Row);
			if (!this.Col.containsKey(ColNames)) {
				this.ColNames.add(ColNames);
				this.Col.put(ColNames, true);
			}
		}
		return true;
	}
	
	public boolean writeMatrix (File matrix) {
        String SColNames = (" \t" + this.ListToString(ColNames));
        List<String> RowsList = new ArrayList<>();
        // this.RowNames.forEach(RowName -> RowsList.add(this.RowGenerator(RowName)));
		try {
	        BufferedWriter bw = null;
	        bw = new BufferedWriter(new FileWriter(matrix));
	        
	        bw.write(SColNames + "\n");
	        
	        // for (String RowName : this.RowNames) {
	        //    bw.write(RowName + "\t" + RowToString(ColNames, Case.get(RowName)) + "\n");
	        // }
	        
	        // for (String Row : RowsList) {
	        //	bw.write(Row);
	        // }
	        for (String RowName : this.RowNames) {
	        	bw.write(this.RowGenerator(RowName));
	        }
	        
	        bw.flush();
			bw.close();
        
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
		
		return true;
	}
	
    public String ListToString(List<String> Line) {
    	if (Line == null) {
    		return "";
    	} else if(Line.size() == 0) {
    		return "";
    	}
    	
    	/** String StringLine = Line.get(0);
    	for (int ir=1; ir<Line.size(); ir++) {
    		StringLine = (StringLine + "\t" + Line.get(ir));
    	} **/
    	
    	List<String> ListLine = new ArrayList<String>();

    	for (int ir=0; ir<Line.size(); ir++) {
    		ListLine.add(Line.get(ir));
    	}
    	
    	String StringLine = String.join("\t",ListLine);
    	
    	return StringLine;
    }
    
    public String RowGenerator(String RowName) {
    	return (RowName + "\t" + RowToString(this.ColNames, this.Case.get(RowName)) + "\n");
    }
    
    public String RowToString(List<String> Col, HashMap<String, String> Row) {
    	// String RowLine = null;
    	String Cell = null;
    	List<String> ListLine = new ArrayList<String>();
    	
    	if (Col == null) {
    		return "";
    	} else if(Col.size() == 0) {
    		return "";
    	}
    	if (Row == null) {
    		// RowLine = " ";
        	for (int ir=0; ir<Col.size(); ir++) {
        		// RowLine = (RowLine + "\t" + " ");
        		ListLine.add(" ");
        	}
    	} else {
        	/** if(Row.containsKey(Col.get(0))) {
            	RowLine = Row.get(Col.get(0));
        	} else {
        		RowLine = "1";
        	} **/
        	for (int ir=0; ir<Col.size(); ir++) {
            	if(Row.containsKey(Col.get(ir))) {
            		// Cell = Row.get(Col.get(ir));
            		ListLine.add(Row.get(Col.get(ir)));
            	} else {
            		// Cell = "1";
            		ListLine.add("1");
            	}
        		// RowLine = (RowLine + "\t" + Cell);
        	}
    	}
    	String RowLine = String.join("\t",ListLine);
    	return RowLine;
    }
    
}
