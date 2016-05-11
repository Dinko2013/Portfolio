import java.awt.Color;
import java.awt.GradientPaint;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.geom.Ellipse2D;

import javax.swing.JPanel;


public class Oval extends Shapes
{
	
	public Oval() {
		x1= 5;
		y1 = 0;
		width = 50;
		height= 100;
	}
	
	@Override public void draw(Graphics g,JPanel jp )
	{	
			color = 0 + myRandom.nextInt(5);
			g.setColor(colorArray[color]);
			g.fillOval(x1,y1,width,height);
			move(jp);

	}
	
		public void move(JPanel jp)
		{
			x1+=dx;
			y1+=dy;
			if(x1<0 || x1>jp.getWidth()-width)
			{
				dx = -dx;
				
			}
			if(y1 <0 || y1 >jp.getHeight()-height)
			{
				dy = -dy;
				
			}
			
		}
		
	}
			
