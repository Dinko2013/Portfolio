import java.awt.Graphics;

import javax.swing.JPanel;


public class Line extends Shapes
{
	
	public Line() {
		x1 = 190;
		y1 = 10;
		width = 60;
		height=50;
	}
	
	
	@Override public void draw(Graphics g,JPanel jp )
	{	
		    color =myRandom.nextInt(5);
			g.setColor(colorArray[color]);
			g.fillRoundRect(x1, y1, width, height, 15, 15);
			move(jp);
}
	public void move(JPanel jp)
	{
		if(x1<0 || x1>jp.getWidth()-width)
		{
			dx = -dx;
		}
		if(y1 <0 || y1 >jp.getHeight()-height)
		{
			dy = -dy;
			
		}
		x1+=dx;
		y1+=dy;
	}
}
