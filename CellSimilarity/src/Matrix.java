import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
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

public class Matrix {
	public static String defaultValue = "1";
	public static String Separator = "\t";
	public Set<String> ColNames = new HashSet<String>();
	HashMap<String, HashMap<String, String>> Case = new HashMap<>();
	
	public Matrix(){
		
	}
	
	public boolean LectureMatCarre(File matrix) {
		try {
			int i = 1;
			int j = 1;
        	BufferedReader br = null;
            br = new BufferedReader(new FileReader(matrix));
            String line = br.readLine();
            String col [] = line.split("\t");
            
            while ((line = br.readLine()) != null) {
            	String cases [] = line.split("\t");
            	while (i < cases.length) {
            		this.insertValue(cases[0],col[i],cases[i]);
            		i++;
            	}
            	j++;
            	i = j;
            }
            br.close();
        } catch (IOException ex) {
            System.err.println(ex);
            return false;
        }
		return true;
	}
	
	public boolean insertValue (String RowName, String ColNames, String Value) {
		if (this.Case.containsKey(RowName)) {
			HashMap<String, String> Row = Case.get(RowName);
			this.ColNames.add(ColNames);
			Row.put(ColNames, Value);
		} else {
			HashMap<String, String> Row = new HashMap<>();
			Row.put(ColNames, Value);
			Case.put(RowName, Row);
			this.ColNames.add(ColNames);
		}
		return true;
	}
	
	public boolean writeMatrix (File matrix) {
		List<String> ColList = new ArrayList<String>(ColNames);
        String SColNames = (" \t" + this.ListToString(ColList));
		try {
	        BufferedWriter bw = null;
	        bw = new BufferedWriter(new FileWriter(matrix));
	        
	        bw.write(SColNames + "\n");
	        
	        for (String RowName : this.Case.keySet()) {
	        	bw.write(this.RowGenerator(RowName,ColList));
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
    	
    	List<String> ListLine = new ArrayList<String>();

    	for (int ir=0; ir<Line.size(); ir++) {
    		ListLine.add(Line.get(ir));
    	}
    	
    	String StringLine = String.join(Separator,ListLine);
    	
    	return StringLine;
    }
    
    public String RowGenerator(String RowName, List<String> ColList) {
    	return (RowName + Separator + RowToString(ColList, this.Case.get(RowName)) + "\n");
    }
    
    public String CaseExtractor(String RowName, String ColName) {
    	String Val = null;
    	if (this.Case.containsKey(RowName)) {
			HashMap<String, String> Row = Case.get(RowName);
			if (Row.containsKey(ColName)) {
				Val = Row.get(ColName);
			}
		}
    	return Val;
    }
    
    public String RowToString(List<String> Col, HashMap<String, String> Row) {
    	List<String> ListLine = new ArrayList<String>();
    	
    	if (Col == null) {
    		return "";
    	} else if(Col.size() == 0) {
    		return "";
    	}
    	if (Row == null) {
        	for (int ir=0; ir<Col.size(); ir++) {
        		ListLine.add(" ");
        	}
    	} else {
        	for (int ir=0; ir<Col.size(); ir++) {
            	if(Row.containsKey(Col.get(ir))) {
            		ListLine.add(Row.get(Col.get(ir)));
            	} else {
            		ListLine.add(defaultValue);
            	}
        	}
    	}
    	String RowLine = String.join(Separator,ListLine);
    	return RowLine;
    }
    
    public String RowToString(List<String> Col, String RowName) {
    	List<String> ListLine = new ArrayList<String>();
    	HashMap<String, String> Row = this.Case.get(RowName);
    	if (Col == null) {
    		return "";
    	} else if(Col.size() == 0) {
    		return "";
    	}
    	if (Row == null) {
        	for (int ir=0; ir<Col.size(); ir++) {
        		ListLine.add(" ");
        	}
    	} else {
        	for (int ir=0; ir<Col.size(); ir++) {
            	if(Row.containsKey(Col.get(ir))) {
            		ListLine.add(Row.get(Col.get(ir)));
            	} else if (Case.get(Col.get(ir)).containsKey(RowName)) {
            		ListLine.add(Case.get(Col.get(ir)).get(RowName));
            	} else {
            		ListLine.add(defaultValue);
            	}
        	}
    	}
    	String RowLine = String.join(Separator,ListLine);
    	return RowLine;
    }
    
}
