
public class Animals 
{
	protected String Animal;
	protected String Sex;
	protected double weight;
	protected Tracker data = new Tracker();;
	
	public String getAnimal() {
		return Animal;
	}
	public void setAnimal(String animal) {
		Animal = animal;
	}
	public String getSex() {
		return Sex;
	}
	public void setSex(String sex) {
		Sex = sex;
	}
	public double getWeight() {
		return weight;
	}
	public void setWeight(double weight) {
		this.weight = weight;
	}

}
