import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;
import java.util.Random;

import javax.swing.JPanel;


public class Star extends Shapes
{
	//prevents graphics errors
	Random random = new Random();	        
	GeneralPath star = new GeneralPath();
	int xpoints[] = {30, 200, 30, 200, 30};
	int ypoints[] = {30, 30, 200, 200, 30};
	int nPoints[] = {5, 5, 9, 9};
	
	public Star() {
		setVariables();
	}
	
	public void draw(Graphics g2d,JPanel jp )
	{
		
		int num = 5; 
		g2d.drawPolygon(xpoints, ypoints, num);
		AffineTransform keep = ((Graphics2D) g2d).getTransform(); 
		for(int i=0; i<xpoints.length;i++)
		{
		g2d.translate(xpoints[i],ypoints[i]);
		}
		//use this to restore gdD
		((Graphics2D) g2d).setTransform(keep); 
		move(jp);

	}
	
	public void move(JPanel jp)
	{
		for(int i=0; i<xpoints.length;i++)
		{
		if(xpoints[i]<0 || xpoints[i]>jp.getWidth())
		{
			dx = -dx;
		}
		}
		for(int i=0; i<ypoints.length;i++)
		{
		if(ypoints[i] <0 || ypoints[i] >jp.getHeight())
		{
			dy = -dy;
			
		}
		}
		for(int i=0; i<xpoints.length;i++)
		{
		xpoints[i]+=dx;
		ypoints[i]+=dy;	
		}
		setVariables();
	}
	
	public void setVariables() {
		x1 = xpoints[0];
		y1 = ypoints[0];
		width = xpoints[1];
		height = ypoints[1];
	}
}


	
