#pragma once
#define _SCL_SECURE_NO_WARNINGS//ignore any unsafe library calls

#include <conio.h>
#include <iostream>
#include <sstream> //for string
#include <algorithm>// for copy()

using namespace std;

class Student {

private:
	string name; // STUDENT NAME
	int size; // SIZE OF THE ARRAY HOLDING STUDENT COURSES
	string *vals=nullptr; // POINTER TO ARRAY MEMORY LOCATION

public:
	Student();
	Student(string n,int s, string*v);
	~Student();
	Student(const Student &s);
	Student& operator =(const Student & s);
	friend ostream &operator <<(ostream &output, Student &s);
	void  getStudentInput();
	void  resetCourseList();
	void setName(string s);

};
