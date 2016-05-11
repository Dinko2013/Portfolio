
public class Master
{
	private static Interface frame;
	
	
	/*This Class is created to get access to all the UI elements in the frame class*/
	public static void main(String [] args)
	{
		frame=new Interface();
		frame.setVisible(true);
	}
	
	public static Interface getPanel()
	{
		return frame;
	}
}
