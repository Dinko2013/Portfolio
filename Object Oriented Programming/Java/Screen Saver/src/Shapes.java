import java.awt.Color;
import java.awt.Graphics;
import java.awt.Rectangle;
import java.util.Random;

import javax.swing.*;


public abstract class Shapes {
	protected Random myRandom = new Random();
	protected Color colorArray[] = {Color.RED,Color.BLUE,Color.GREEN,
			Color.YELLOW,Color.MAGENTA};
	protected int x1;
	protected int y1;
	protected int width;
	protected int height;
	protected int color = 0;
	protected double dx=10,dy=10;
	
	
	public int getX1() {
		return x1;
	}


	public void setX1(int x1) {
		this.x1 = x1;
	}


	public int getY1() {
		return y1;
	}


	public void setY1(int y1) {
		this.y1 = y1;
	}


	public int getWidth() {
		return width;
	}


	public void setWidth(int width) {
		this.width = width;
	}


	public int getHeight() {
		return height;
	}


	public void setHeight(int height) {
		this.height = height;
	}
	
	public abstract void draw(Graphics g,JPanel jp );
	
	public Rectangle getBound() {
		return new Rectangle(x1,y1,width,height);
	}
	
	public boolean collided(Shapes otherShape) {
		return otherShape.getBound().intersects(getBound());
	}
	
	public void resolveCollision(Shapes otherShape) {
		double radians = Math.atan2(otherShape.y1 - y1, otherShape.x1 - x1);
		double speed = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2));
		dx = speed * Math.cos(radians) * (dx / (dx * -1));
		dy = speed * Math.sin(radians) * (dy / (dy * -1));
	}
	
}//end class
