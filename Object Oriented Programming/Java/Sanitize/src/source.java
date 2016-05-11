import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

public class source 
{
	static ArrayList<String> reportName =  new ArrayList<>();
	static ArrayList<String> reportPath =  new ArrayList<>();
	static ArrayList<String> reportNameFirstSplit =  new ArrayList<>();
	static ArrayList<String> reportNameSecondSplit = new ArrayList<>();
	static ArrayList<String> reportPathFirstSplit =  new ArrayList<>();
	static ArrayList<String> reportPathSecondSplit = new ArrayList<>();
	static ArrayList<String> reportPathThirdSplit = new ArrayList<>();
	static ArrayList<String> reportNameResults = new ArrayList<>();
	static ArrayList<String> reportPathResults = new ArrayList<>();
	
	public void read(String fileName)
	{
	BufferedReader br;
    try {
         br = new BufferedReader(new FileReader(fileName));
         try {
              String x;
              while((x = br.readLine()) != null )
              {
                String [] values = x.split(",");
                reportName.add(values[0]);
                reportPath.add(values[1]);
              } 
            } 
         catch (IOException e)
         {
            e.printStackTrace();
         }
        } catch (FileNotFoundException e)
    {
            System.out.println(e);
            e.printStackTrace();
   }
	}
	
	public  void Clean(ArrayList<String> raw,ArrayList<String> clean ,String splitChar ,int offset)
	{
		String x;
		for(int i =0;i<raw.size();i++)
		{
			x = raw.get(i);
			String[] splitValues = x.split(splitChar);
			clean.add(splitValues[1]);
		}
			for(int i =0; i<clean.size();i++)
			{
				String y;
				y=clean.get(i);
				
				if(y.startsWith("'"))
				{
					 y = y.substring(1,y.length());
				}
				if(y.endsWith("']"))
				{
					y = y.substring(0,y.length()-offset);
				}
				clean.set(i, y);
			}
		}
	public  void Clean1(ArrayList<String> raw,ArrayList<String> clean ,String splitChar ,int offset)
	{
		String x;
		for(int i =0;i<raw.size();i++)
		{
			x = raw.get(i);
			String[] splitValues = x.split(splitChar);
			clean.add(splitValues[1]);
		}
			for(int i =0; i<clean.size();i++)
			{
				String y;
				y=clean.get(i);
				if(y.contains("="))
				{
					String[] ySplit = y.split("=");
					y=ySplit[1];
				}
				if(y.startsWith("'"))
				{
					 y = y.substring(1,y.length());
				}
				if(y.endsWith("'"))
				{
					y = y.substring(0,y.length()-offset);
				}
				clean.set(i, y);
			}
		}
	
	public void write(String fileName)
	{
		BufferedWriter bw;
		try {
			bw = new BufferedWriter(new FileWriter(fileName));
			for(int i =0; i<reportNameResults.size();i++)
		{	
			bw.write(reportNameResults.get(i) +"," +reportPathResults.get(i) + "\n");
		}
			bw.close();
		}
		  catch (IOException e)
		  {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
					
	}

	public static void main(String [] args)
	{
		
		source s = new source();
		
		System.out.println("welcome");
		s.read("report.csv");
		s.Clean(reportName,reportNameResults,"=",2);
		s.Clean1(reportPath,reportPathResults,"]",1);
		s.write("Result.csv");
		System.out.println("Done, check File");
		
	}
}