
public class SeaLions extends Animals
{

	private int numberOfSpots;
	
	public SeaLions()// Default
	{
		
	}
	public SeaLions(String type,String sex,double weight, int numberOfSpots,String coordinates)
	{
		type=this.getAnimal();
	 	sex = this.getSex();
	 	weight=this.getWeight();
	 	numberOfSpots=this.getNumberOfSpots();
	 	coordinates=this.data.getGpsData();
	}

	public int getNumberOfSpots() {
		return numberOfSpots;
	}

	public void setNumberOfSpots(int numberOfSpots) {
		this.numberOfSpots = numberOfSpots;
	}
}
