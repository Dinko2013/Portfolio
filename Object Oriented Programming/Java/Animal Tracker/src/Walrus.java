
public class Walrus extends Animals
{
	
	protected String dHealth;
	
	public Walrus()
	{
		
	}
	public Walrus(String type,String sex,double weight, String dHealth,String coordinates)
	{
		type=this.getAnimal();
	 	sex = this.getSex();
	 	weight=this.getWeight();
	 	dHealth=this.getdHealth();
	 	coordinates=this.data.getGpsData();
	}

	public String getdHealth() {
		return dHealth;
	}

	public void setdHealth(String dHealth) {
		this.dHealth = dHealth;
	}
	
	
}
