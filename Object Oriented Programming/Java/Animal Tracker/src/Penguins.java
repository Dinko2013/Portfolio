
public class Penguins extends Animals
{

	private double bloodPressure;
	
	public Penguins()//default
	{
		
	}
	
	public Penguins(String type,String sex,double weight, double bP,String coordinates)
	{
	 	type=this.getAnimal();
	 	sex = this.getSex();
	 	weight=this.getWeight();
	 	bP=this.getBloodPressure();
	 	coordinates=this.data.getGpsData();
	}
	public double getBloodPressure() {
		return bloodPressure;
	}

	public void setBloodPressure(double bloodPressure) {
		this.bloodPressure = bloodPressure;
	}
}
