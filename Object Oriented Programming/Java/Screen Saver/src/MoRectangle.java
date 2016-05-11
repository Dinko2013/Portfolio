import java.awt.Graphics;

import javax.swing.JPanel;


public class MoRectangle extends Shapes
{
	
	public MoRectangle() {
		x1 = 5;
		y1 = 357;
		width = 50;
		height = 100;
	}

	@Override public void draw(Graphics g,JPanel jp )
	{
			
			color = 0 + myRandom.nextInt(5);
			g.setColor(colorArray[color]);
			g.fillRect(x1,y1,width,height);
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
