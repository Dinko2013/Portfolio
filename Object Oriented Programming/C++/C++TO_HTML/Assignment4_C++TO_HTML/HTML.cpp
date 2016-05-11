
#include <iostream>
#include <fstream>
#include <conio.h>
#include <regex>
#include "HTML.h"


string HTML::getCppFileName()
{
	string temp;
	string fileName;
	bool isValid = false;
	cout << "Enter name of the CPP file i.e. 'filename.cpp': ";
	while (isValid == false)
	{
		getline(cin, temp);

	if (std::regex_match(temp, std::regex("[0-9a-zA-Z_-]+[.][c][p][p]{1}"))) {
			isValid = true;
			fileName = temp;
		}
		else {
			cout << "Sorry :(, Invalid File Name. Please enter file name: ";
			isValid = false;
		}
	}

	return fileName;
}

string HTML::getHtmlFileName()
{
	string temp;
	string fileName;
	bool isValid = false;
	cout << "Enter name of the HTML file i.e. 'filename.html': ";
	while (isValid == false)
	{
		getline(cin, temp);

		if (std::regex_match(temp, std::regex("[0-9a-zA-Z_-]+[.][h][t][m][l]{1}"))) {
			isValid = true;
			fileName = temp;
		}
		else {
			cout << "Sorry :(, Invalid File Name. Please enter file name: " ;
			isValid = false;
		}
	}

	return fileName;
}
void HTML::seekAndDestroy(string cpp_file_name, string html_file_name)
{

	ifstream inStream(cpp_file_name);
	ofstream outStream(html_file_name);
	string readLine;

		
		if (inStream.fail())
		{
			cout << "Could not find " << cpp_file_name<< endl;

		}
		else
		{
			try {

				if (outStream.fail())
				{
					cout << "Could not Write to " << html_file_name << endl;
				}
				else
				{
					outStream << "<PRE>";

					while (!inStream.eof()) {

						getline(inStream, readLine);

						for (std::string::size_type i = 0; i < readLine.size(); ++i) {

							if (readLine[i] == '>') {
								outStream << "&gt";
							}
							else if (readLine[i] == '<') {
								outStream << "&lt";
							}
							else {
								outStream << readLine[i];
							}

						}

						outStream << endl;

					}

					outStream << "</PRE>";
					outStream.close();
					inStream.close();
					cout << "File Saved" << endl;
				}
		
		}
		catch (exception e) {
			cout << "Failed reading file" << endl;
		}
	
		
	}

}

bool HTML::shouldIContinue()
{

	string choice; 
	bool start=false;
	bool isValid = true;

	cout << "Please Enter 'Y' to convert a new CPP file: "<<endl;
	cout << "OR Enter 'N' to exit this assignment" << endl;

	
	while (isValid)
	{

		getline(cin, choice);


		if (choice == "y" || choice == "Y")
		{
			start = true;
			isValid = false;
		}
		else if (choice == "n" || choice == "N") 
		{
												
			start = false;
			isValid = false;
		}
		else {									
			cout << "Please enter y or n." << endl;
		}

	}

	return start;
}


