import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.*;

import javax.swing.JOptionPane;


public class DirtyClass
{
		protected String Species;
		protected String Sex;
		protected double weight;
		protected double bloodPressure;
		protected String dentalHealth;
		protected int spots;
		protected String Lon;
		protected String Lat;
		protected String Coordinates ;
		String temp1,temp2,temp3,temp4,temp5;
		ArrayList<String> myAnimal = new ArrayList();
		
		/*Set the enable feature to true for corresponding unique form element of the selected animal */
		public void Activate()
		{
			if(Master.getPanel().getCboAnimalType().getSelectedIndex()==0)
    		{
    			Master.getPanel().txtPenguinBP.setEnabled(true);
    		}
    		else if(Master.getPanel().getCboAnimalType().getSelectedIndex()==1)
    		{
    			Master.getPanel().txtSeaLionS.setEnabled(true);
    		}
    		else
    		{
    			Master.getPanel().cboWalrusDH.setEnabled(true);
    		}
		}
		
		/*Handles Penguin selection*/
		public void validateAndAssignVariablesPenguin()
		{
			Species=(String) Master.getPanel().cboAnimalType.getSelectedItem();
			Sex = (String) Master.getPanel().cboAnimalSex.getSelectedItem();
			temp1 = Master.getPanel().getTextAnimalWeight().getText();
			
			if(validateWeight(temp1)==true)
			{
				weight= parseDouble(temp1);
			}
			else
			{
				JOptionPane.showMessageDialog(null, "Invalid Weight Entered");
				
			}
			temp2 = Master.getPanel().getTxtPenguinBP().getText();
			if(validateBP(temp2)==true)
			{
				bloodPressure=parseDouble(temp2);
			}
			else
			{
				JOptionPane.showMessageDialog(null, "Invalid Blood Pressure Entered");
			}
			temp4 = Master.getPanel().getTxtLong().getText();
			temp5 = Master.getPanel().getTxtLat().getText();
			
			if(validateCoordi(temp4,temp5) == true)
			{
				Coordinates = temp4 +","+temp5;
			}
			else
			{
				JOptionPane.showMessageDialog(null, "Invalid Gps Data Entered");
			}
			
			if((validateWeight(temp1)==true) &&(validateBP(temp2)==true) &&validateCoordi(temp4,temp5) == true)
			{
				Penguins penguin =new Penguins();
				penguin.setAnimal(Species);
				penguin.setSex(Sex);
				penguin.setWeight(weight);
				penguin.setBloodPressure(bloodPressure);
				penguin.data.setGpsData(Coordinates);
				
				String Penguin = penguin.getAnimal() +" - "+penguin.getSex()+" - "+penguin.getWeight()+" - "+penguin.getBloodPressure()+" - ("+penguin.data.getGpsData()+")";
				myAnimal.add(Penguin);
				Master.getPanel().gettAreaReport().append("New Animal Record Added"+ "\n");
				ResetPenguin();
			}
			else
			{
				Master.getPanel().gettAreaReport().append("Record Not Added"+ "\n");
			}
			
			
		}
		
		/*Handles SeaLion Selection*/
		public void validateAndAssignVariablesSeaLion()
		{
			
			Species=(String) Master.getPanel().getCboAnimalType().getSelectedItem();
			Sex = (String) Master.getPanel().getCboAnimalSex().getSelectedItem();
			temp1 =Master.getPanel().getTextAnimalWeight().getText();
			if(validateWeight(temp1)==true)
			{
				weight=parseDouble(temp1);
			}
			else
			{
				JOptionPane.showMessageDialog(null, "Invalid Weight Entered");
			}
			temp3 = Master.getPanel().getTxtSeaLionS().getText();
			if(validateSpots(temp3)==true)
			{
				spots=Integer.parseInt(temp3);
			}
			else
			{
				JOptionPane.showMessageDialog(null, "Invalid Number of Spots Entered");
			}
			
			temp4 = Master.getPanel().getTxtLong().getText();
			temp5 = Master.getPanel().getTxtLat().getText();
			
			if(validateCoordi(temp4,temp5) == true)
			{
				Coordinates = temp4 +","+temp5;
			}
			else
			{
				JOptionPane.showMessageDialog(null, "Invalid Gps Data Entered");
			}
			
			if((validateWeight(temp1)==true) &&(validateSpots(temp3)==true) &&validateCoordi(temp4,temp5) == true)
			{
			SeaLions sealion =new SeaLions();
			sealion.setAnimal(Species);
			sealion.setSex(Sex);
			sealion.setWeight(weight);
			sealion.setNumberOfSpots(spots);
			sealion.data.setGpsData(Coordinates);
			String SeaLion = sealion.getAnimal() +" - "+sealion.getSex()+" - "+sealion.getWeight()+" - "+sealion.getNumberOfSpots()+" - ("+sealion.data.getGpsData() + ")";
			myAnimal.add(SeaLion);
			Master.getPanel().gettAreaReport().append("New Animal Record Added"+ "\n");
			ResetSeaLion();
			}
			else
			{
				Master.getPanel().gettAreaReport().append("Record Not Added"+ "\n");
			}
		}
		
		/*Handles Walrus Selection*/
		public void validateAndAssignVariablesWalrus()
		{
			
			Species=(String) Master.getPanel().getCboAnimalType().getSelectedItem();
			Sex = (String) Master.getPanel().getCboAnimalSex().getSelectedItem();
			dentalHealth = (String)Master.getPanel().getCboWalrusDH().getSelectedItem();
			temp1=Master.getPanel().getTextAnimalWeight().getText();
			
			if(validateWeight(temp1)==true)
			{
				weight=parseDouble(temp1);
			}
			else
			{
				JOptionPane.showMessageDialog(null, "Invalid Weight Entered");
			}
			temp4 = Master.getPanel().getTxtLong().getText();
			temp5 = Master.getPanel().getTxtLat().getText();
			
			if(validateCoordi(temp4,temp5) == true)
			{
				Coordinates = temp4 +","+temp5;
			}
			else
			{
				JOptionPane.showMessageDialog(null, "Invalid Gps Data Entered");
			}
			
			
			if((validateWeight(temp1)==true) &&validateCoordi(temp4,temp5) == true)
			{
				Walrus walrus =new Walrus();
				walrus.setAnimal(Species);
				walrus.setSex(Sex);
				walrus.setWeight(weight);
				walrus.setdHealth(dentalHealth);
				walrus.data.setGpsData(Coordinates);
				String Walrus = walrus.getAnimal() +" - "+walrus.getSex()+" - "+walrus.getWeight()+" - "+walrus.getdHealth()+" - ("+walrus.data.getGpsData()+")";
				myAnimal.add(Walrus);
				Master.getPanel().gettAreaReport().append("New Animal Record Added"+ "\n");
				ResetWalrus();
			}
			else
			{
				Master.getPanel().gettAreaReport().append("Record Not Added"+ "\n");
			}
			
		}
		
		/* validates submitted weight and */
		public boolean validateWeight(String value)
		{
			String line = value;
			String pattern = ("[0-9]{1,13}(\\.[0-9]+)?");
			Pattern r = Pattern.compile(pattern);
			Matcher m = r.matcher(line);
			if(m.find())
			{	
				return true;
			}
			else
			{
				return false;
			}

		}
		public boolean validateBP(String value)
		{
			String line = value;
			String pattern = "\\d+\\.\\d*";
			Pattern r = Pattern.compile(pattern);
			Matcher m = r.matcher(line);
			if(m.find())
			{	
				return true;
			}
			else
			{
				return false;
			}

		}
		/**/
		public boolean validateSpots(String value)
		{
			String line = value;
			String pattern = "^\\d+$";
			Pattern r = Pattern.compile(pattern);
			Matcher m = r.matcher(line);
			if(m.find())
			{	
				return true;
			}
			else
			{
				return false;
			}
		}
		/**/
		public boolean validateCoordi(String value1,String value2)
		{
			String line = value1 +","+ value2;
			String pattern = "([+-]?\\d+\\.?\\d+),([+-]?\\d+\\.?\\d+)";
			Pattern r = Pattern.compile(pattern);
			Matcher m = r.matcher(line);
			if(m.find())
			{	
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**/
		public void writeToFile() 

		{
			try{
			File myfile = new File("data.txt");
			FileWriter wtf = new FileWriter(myfile.getAbsolutePath(),true);
			BufferedWriter writer = new BufferedWriter(wtf);
			PrintWriter printer = new PrintWriter(writer);
			for (int i = 0;i<myAnimal.size();i++)
			{
				
				printer.println(myAnimal.get(i));
			}
			writer.close();
		}catch (IOException e)
			{
			System.out.println(e.getMessage());
			e.printStackTrace();
			}
		}
		
		/**/
		public void Report()
		{	
			Master.getPanel().gettAreaReport().setText("");	
			String x = JOptionPane.showInputDialog("Please Enter The Name of The File You Want to Read");
			Master.getPanel().gettAreaReport().append("************************************************"+"\n");
			try
			{
				BufferedReader br = new BufferedReader(new FileReader(x));
				String sCurrentLine;
				int count =1;
				Master.getPanel().gettAreaReport().append("The Collected is as follows" +"\n" );
				while((sCurrentLine=br.readLine())!=null)//while stuff to read
				{
					Master.getPanel().gettAreaReport().append("Record # " +count+ ": "+sCurrentLine + "\n");
					Master.getPanel().gettAreaReport().append("--------------------------------------------------"+"\n");
					count++;
				}
				br.close();
			}
			catch(IOException e)//only IO exception types
			{
				System.out.println(e.getMessage());//explain error to user
				e.printStackTrace();
			}
			catch(Exception e)//any exception type
			{
				System.out.println(e.getMessage());//explain error to user
				e.printStackTrace();
			}
			
		}
		
		/**/
		public void readFile()
		{
			Master.getPanel().gettAreaReport().setText("");
			String x = JOptionPane.showInputDialog("Please Enter The Name of The File You Want to Read");
			
			try
			{
				BufferedReader br = new BufferedReader(new FileReader(x));
				String sCurrentLine;
				while((sCurrentLine=br.readLine())!=null)//while stuff to read
				{
					Master.getPanel().gettAreaReport().append(sCurrentLine + "\n");
				}
				br.close();
			}
			catch(IOException e)//only IO exception types
			{
				System.out.println(e.getMessage());//explain error to user
				e.printStackTrace();
			}
			catch(Exception e)//any exception type
			{
				System.out.println(e.getMessage());//explain error to user
				e.printStackTrace();
			}
			
		}//end doRead()
		
	
		private double parseDouble(String temp12) {
			if (temp12 != null && temp12.length() > 0) {
			       try {
			          return Double.parseDouble(temp12);
			       } catch(Exception e) {
			          return -1;  
			       }
			   }
			   else return 0;
		}
		/**/
 		public void ResetPenguin(){
			
			Master.getPanel().getCboAnimalSex().setSelectedIndex(0);
			Master.getPanel().getCboAnimalSex().setSelectedIndex(0);
			Master.getPanel().getTextAnimalWeight().setText("");
			Master.getPanel().getTxtPenguinBP().setText("");
			Master.getPanel().getTxtLong().setText("");
			Master.getPanel().getTxtLat().setText("");
			
		}
 		/**/
		public void ResetSeaLion(){
	Master.getPanel().getCboAnimalSex().setSelectedIndex(0);
	Master.getPanel().getCboAnimalSex().setSelectedIndex(0);
	Master.getPanel().getTextAnimalWeight().setText("");
	Master.getPanel().getTxtSeaLionS().setText("");
	Master.getPanel().getTxtLong().setText("");
	Master.getPanel().getTxtLat().setText("");
		}
		
		/**/
		public void ResetWalrus(){
	Master.getPanel().getCboAnimalSex().setSelectedIndex(0);
	Master.getPanel().getCboAnimalSex().setSelectedIndex(0);
	Master.getPanel().getTextAnimalWeight().setText("");
	Master.getPanel().getCboWalrusDH().setSelectedIndex(0);
	Master.getPanel().getTxtLong().setText("");
	Master.getPanel().getTxtLat().setText("");
	
}
		
}
