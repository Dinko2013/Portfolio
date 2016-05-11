import java.awt.BorderLayout;
import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;

import java.awt.CardLayout;

import javax.swing.JLabel;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;
import javax.swing.JTextPane;
import javax.swing.JButton;
import javax.swing.JTextArea;
import javax.swing.DefaultComboBoxModel;
import javax.swing.SwingConstants;
import javax.swing.border.LineBorder;

import java.awt.Color;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;


public class Interface extends JFrame {

	private JPanel contentPane;
	protected JComboBox cboAnimalSex;
	protected JTextPane textAnimalWeight;
	protected JTextPane txtPenguinBP;
	protected JTextArea tAreaReport;
	protected JComboBox cboAnimalType;
	protected JComboBox cboWalrusDH;
	protected JTextArea txtSeaLionS;
	protected JTextArea txtLong;
	protected JTextArea txtLat;
	
	
	public JComboBox getCboAnimalSex() {
		return cboAnimalSex;
	}

	public void setCboAnimalSex(JComboBox cboAnimalSex) {
		this.cboAnimalSex = cboAnimalSex;
	}

	public JTextPane getTextAnimalWeight() {
		return textAnimalWeight;
	}

	public void setTextAnimalWeight(JTextPane textAnimalWeight) {
		this.textAnimalWeight = textAnimalWeight;
	}

	public JTextPane getTxtPenguinBP() {
		return txtPenguinBP;
	}

	public void setTxtPenguinBP(JTextPane txtPenguinBP) {
		this.txtPenguinBP = txtPenguinBP;
	}

	public JTextArea gettAreaReport() {
		return tAreaReport;
	}

	public void settAreaReport(JTextArea tAreaReport) {
		this.tAreaReport = tAreaReport;
	}

	public JComboBox getCboAnimalType() {
		return cboAnimalType;
	}

	public void setCboAnimalType(JComboBox cboAnimalType) {
		this.cboAnimalType = cboAnimalType;
	}

	public JComboBox getCboWalrusDH() {
		return cboWalrusDH;
	}

	public void setCboWalrusDH(JComboBox cboWalrusDH) {
		this.cboWalrusDH = cboWalrusDH;
	}

	public JTextArea getTxtSeaLionS() {
		return txtSeaLionS;
	}

	public void setTxtSeaLionS(JTextArea txtSeaLionS) {
		this.txtSeaLionS = txtSeaLionS;
	}

	public JTextArea getTxtLong() {
		return txtLong;
	}

	public void setTxtLong(JTextArea txtLong) {
		this.txtLong = txtLong;
	}

	public JTextArea getTxtLat() {
		return txtLat;
	}

	public void setTxtLat(JTextArea txtLat) {
		this.txtLat = txtLat;
	}

	DirtyClass get = new DirtyClass();
	/**
	 * Launch the application.
	 */

	/**
	 * Create the frame.
	 */
	public Interface() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 830, 419);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		contentPane.setLayout(new CardLayout(0, 0));
		
		JPanel panel = new JPanel();
		contentPane.add(panel, "name_419169122578894");
		panel.setLayout(null);
		
		JLabel lblNewLabel_1 = new JLabel("Animal Sex");
		lblNewLabel_1.setHorizontalAlignment(SwingConstants.LEFT);
		lblNewLabel_1.setBounds(10, 43, 114, 14);
		panel.add(lblNewLabel_1);
		
		cboAnimalSex = new JComboBox();
		cboAnimalSex.setModel(new DefaultComboBoxModel(new String[] {"Male", "Female"}));
		cboAnimalSex.setBounds(163, 40, 155, 20);
		panel.add(cboAnimalSex);
		
		JLabel lblNewLabel_2 = new JLabel("Animal Weight");
		lblNewLabel_2.setHorizontalAlignment(SwingConstants.LEFT);
		lblNewLabel_2.setBounds(10, 77, 114, 14);
		panel.add(lblNewLabel_2);
		
		textAnimalWeight = new JTextPane();
		textAnimalWeight.setBounds(163, 71, 155, 20);
		panel.add(textAnimalWeight);
		
		JLabel lblPenguinbp = new JLabel("Blood Pressure");
		lblPenguinbp.setHorizontalAlignment(SwingConstants.LEFT);
		lblPenguinbp.setBounds(10, 108, 104, 14);
		panel.add(lblPenguinbp);
		
		txtPenguinBP = new JTextPane();
		txtPenguinBP.setEnabled(false);
		txtPenguinBP.setBounds(163, 102, 155, 20);
		panel.add(txtPenguinBP);
		
		JButton btnRecord = new JButton("Record");
		btnRecord.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) 
			{
				
					if(cboAnimalType.getSelectedIndex()==0)
					{
						get.validateAndAssignVariablesPenguin();
					}
					else if(cboAnimalType.getSelectedIndex()==1)
					{
						get.validateAndAssignVariablesSeaLion();
					}
					else if(cboAnimalType.getSelectedIndex()==2)
					{
						get.validateAndAssignVariablesWalrus();
					}
				
			}
		});
		btnRecord.setBounds(0, 321, 80, 23);
		panel.add(btnRecord);
		
		JButton btnWritetoFile = new JButton("Write");
		btnWritetoFile.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0)
			{
				get.writeToFile();
			}
		});
		btnWritetoFile.setBounds(90, 321, 70, 23);
		panel.add(btnWritetoFile);
		
		JButton btnReport = new JButton("Report");
		btnReport.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) 
			{
				get.Report();
			}
		});
		btnReport.setBounds(248, 321, 83, 23);
		panel.add(btnReport);
		
		tAreaReport = new JTextArea();
		tAreaReport.setLineWrap(true);
		tAreaReport.setBounds(336, 11, 450, 353);
		panel.add(tAreaReport);
		
		JLabel lblAnimalType = new JLabel("Animal Type");
		lblAnimalType.setHorizontalAlignment(SwingConstants.LEFT);
		lblAnimalType.setBounds(10, 16, 70, 14);
		panel.add(lblAnimalType);
		
	    cboAnimalType = new JComboBox();
	    cboAnimalType.addActionListener(new ActionListener() {
	    	public void actionPerformed(ActionEvent arg0) {
	    		get.Activate();
	    	}
	    });
		cboAnimalType.setModel(new DefaultComboBoxModel(new String[] {"Peguins", "Sea Lion", "Walrus"}));
		cboAnimalType.setBounds(163, 6, 155, 20);
		panel.add(cboAnimalType);
		
		JLabel lblNewLabel = new JLabel("Dental Health");
		lblNewLabel.setHorizontalAlignment(SwingConstants.LEFT);
		lblNewLabel.setBounds(10, 140, 71, 14);
		panel.add(lblNewLabel);
		
		JLabel lblNewLabel_3 = new JLabel("Spots");
		lblNewLabel_3.setHorizontalAlignment(SwingConstants.LEFT);
		lblNewLabel_3.setBounds(10, 177, 71, 14);
		panel.add(lblNewLabel_3);
		
	    cboWalrusDH = new JComboBox();
		cboWalrusDH.setEnabled(false);
		cboWalrusDH.setModel(new DefaultComboBoxModel(new String[] {"Good ", "Average", "Poor"}));
		cboWalrusDH.setBounds(163, 137, 155, 20);
		panel.add(cboWalrusDH);
		
		txtSeaLionS = new JTextArea();
		txtSeaLionS.setEnabled(false);
		txtSeaLionS.setBounds(163, 172, 155, 22);
		panel.add(txtSeaLionS);
		
		JPanel Coordinates = new JPanel();
		Coordinates.setBorder(new LineBorder(new Color(0, 0, 0)));
		Coordinates.setBounds(10, 218, 308, 92);
		panel.add(Coordinates);
		Coordinates.setLayout(null);
		
		JLabel lblNewLabel_4 = new JLabel("Coordinates");
		lblNewLabel_4.setBounds(124, 11, 94, 14);
		Coordinates.add(lblNewLabel_4);
		
		JLabel lblNewLabel_5 = new JLabel("Longitute");
		lblNewLabel_5.setBounds(10, 30, 56, 14);
		Coordinates.add(lblNewLabel_5);
		
		JLabel lblLattitude = new JLabel("Lattitude");
		lblLattitude.setBounds(10, 67, 56, 14);
		Coordinates.add(lblLattitude);
		
		txtLong = new JTextArea();
		txtLong.setBounds(89, 25, 177, 22);
		Coordinates.add(txtLong);
		
		txtLat = new JTextArea();
		txtLat.setBounds(89, 62, 177, 22);
		Coordinates.add(txtLat);
		
		JButton btnRead = new JButton("Read");
		btnRead.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				get.readFile();
			}
		});
		btnRead.setBounds(171, 321, 70, 23);
		panel.add(btnRead);
	}
}
