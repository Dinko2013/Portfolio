#define _SCL_SECURE_NO_WARNINGS//ignore any unsafe library calls
#include <conio.h>
#include <iostream>
#include "Student.h"

using namespace std;

int main()
{
	Student stud;
	string name;

	string again="";

	while(again != "n")
	{ 
	cout << "--------------------------------------------------------------"<<endl;
	stud.getStudentInput();
	cout << "Student 1's Data" << endl;
	cout << stud;

	cout << "Enter Student 2's Name: ";
	cin >> name;
	Student stud2;
	stud2.setName(name);
	stud2.resetCourseList();
	stud2 = stud;
	cout << stud2;
	stud.resetCourseList();
	cout << "Reset Method Fired for student 1"<< endl;
	cout<< stud;
	cout << "Student 2's Data, should still have the original Classes: " << endl;
	cout << stud2;
	cout << "" << endl;



	cout << "Copy Constructor used to make a third student, the same as Student 2" << endl;
	Student stud3(stud2);
	cout << "Enter Student 3's Name: ";
	cin >> name;
	stud3.setName(name);
	cout << stud3;



	cout << "" << endl;

	//stud3.resetCourseList();
	//stud3.~Student();

	//stud2.resetCourseList();
	//stud2.~Student();

	//stud.resetCourseList();
	//stud.~Student();
	cout << "--------------------------------------------------------------"<<endl;
	cout << "Start again: ";
	cin >> again;
	}
	_getch();
	return 0;

}
