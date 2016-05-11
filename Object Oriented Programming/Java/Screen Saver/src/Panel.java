import java.awt.Color;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Random;

import javax.swing.JPanel;
import javax.swing.Timer;
import javax.swing.JButton;

public class Panel extends JPanel {
	private final int ANIMATION_DELAY = 20;
	Timer animationTimer = new Timer(ANIMATION_DELAY,new TimerHandler());
	 ArrayList <Shapes> s =new ArrayList<Shapes>( Arrays.asList((Shapes) new Oval(),(Shapes) new Line(),(Shapes) new MoRectangle()));
	 
	public Panel() 
	{
		setLayout(null);
		
		JButton btnAddShapes = new JButton("Add Shapes");
		btnAddShapes.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) 
			{
				addshape();
			}
		});
		btnAddShapes.setBounds(233, 189, 121, 23);
		add(btnAddShapes);
		animationTimer.start();
	
	}//end constructor

	
	@Override public void paintComponent(Graphics g)
	{
//		System.out.println("paint c");
//		System.out.println(s);
//		System.out.println(s.size()); 
		super.paintComponent(g);
		this.setBackground(Color.BLACK);
		for(int i=0; i<s.size();i++)
		{
			s.get(i).draw(g, this);
			//System.out.println(shapes.size());
		}

	}//end paintComponent
	public void addshape()
	{
	
			s.add((Shapes) new Line());
			s.add((Shapes) new Oval());
			s.add((Shapes) new MoRectangle());
			//s.add((Shapes) new Star());
	}
	
	private void doCollision() {
		for (int i=0;i<s.size();i++)
			for (int j=i+1;j<s.size();j++)
				if(s.get(i).collided(s.get(j))) {
					s.get(i).resolveCollision(s.get(j));
					s.get(j).resolveCollision(s.get(i));
				}
	}
	
	private class TimerHandler implements ActionListener
	{

		@Override
		public void actionPerformed(ActionEvent actionEvent)
		{
			doCollision();
			repaint();//calls paintComponent
			
			
		}
		
	}//end inner class TimerHandler
}//end class
