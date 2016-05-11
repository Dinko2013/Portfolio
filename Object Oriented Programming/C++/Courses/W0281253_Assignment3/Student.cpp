#define _SCL_SECURE_NO_WARNINGS//ignore any unsafe library calls

#include <conio.h>
#include <iostream>
#include <vector>
#include <sstream> //for string
#include <algorithm>// for copy()
#include "Student.h"

using namespace std;

Student::Student() //DEFAULT CONSTRUCTOR
{
	this->name = name;
	this->size = size;
	this->vals = vals;

}
Student::Student( string n,int s, string *v) // CONSTRUCTOR WITH ARGUMENTS
{
	this->name = n;
	this->size = s;
	this->vals = new string[size];
	copy(v, v + size, this->vals);

}

Student::~Student() //DESTRUCTOR METHOD
{
	if (vals != NULL)
	{
		cout << "Destructor Method Fired for " << this->name << endl;
		delete[] vals;
		this->size = 0;
		this->name = "";
		this->vals = vals;
	}
	
	
}

Student::Student(const Student &s) // COPY METHOD 1 IMPLEMENTATION
{
	size = s.size;
	this->vals = new string[size];
	copy(s.vals, size + s.vals, this->vals);
	cout << "Copy Constuctor Fired!"<< endl;
}

Student& Student:: operator =(const Student & s) // COPY ASSIGNMENT OVERLOAD IMPLEMENTATION
{
	if (&s != this)
	{
		size = s.size;
		this->vals = new string[size];
		copy(s.vals, size + s.vals, this->vals);
		return *this;
	}
	
}
void Student::getStudentInput() // DYNAMIC INPUT IMPLEMENTATION
{ 
	cout << "Enter Student name: ";
	cin >> this->name;
	string *temp_array = nullptr;
	string cName;
	int arraySize =1;
	int courseCount = 0;

	while (cName.compare("done") != 0)
	{
		cout << "Enter a new Course: ";
		cin >> cName;
		cout << " " << endl;

		if (cName.compare("done") != 0)
		{
			auto courses = new string[courseCount + 1];
			for (int i = 0; i < courseCount; i++)
			{
				courses[i] = temp_array[i];
			}
			courses[courseCount++] = cName;
			delete[] temp_array;
			temp_array = courses;
		}

	}

	this->size = courseCount;
	vals = new string[size];
	copy(temp_array, temp_array + size,this->vals);
	}

 ostream& operator <<(ostream &output, Student &s) //<< OVERLOAD IMPLEMENTATION
 {
	 cout << "Name of Student: " << s.name << endl;
	 cout << "Number of Courses: " << s.size << endl;
	 cout << "Class List:" << endl;
	 for (int i = 0; i < s.size; i++)
	 {
		 cout << i + 1 << ") " << s.vals[i] << endl;
	 }

	 return output;
 }
 void Student::resetCourseList()  // RESET COURSE LIST ARRAY
 {
	 if (this->size!=0)
	 {
		 this->vals = 0;
		 this->size = 0;
	 }
		
 }

 void Student::setName(string s) // GET STUDENT NAME
 {
	 this->name = s;
 }