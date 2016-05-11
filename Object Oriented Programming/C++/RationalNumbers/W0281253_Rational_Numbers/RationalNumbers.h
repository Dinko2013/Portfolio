#pragma once
// RationalNumbers header file
//List the methods here
//square()

#include <iostream>
#include <sstream>
#include <conio.h>

#ifndef RationalNumbers_H
#define RATIONALNUMBERS_H
using namespace std;

class RationalNumbers //do not define this again
{
private:
	int numerator;
	int denominator;



public:
	/*********************************Constructors********************************/
	RationalNumbers();// default
	RationalNumbers(int num, int den);// two number
	RationalNumbers(int number);//whole number
	virtual ~RationalNumbers(void);//destructor

	/******************************define nomalization routine*********************************/
	friend RationalNumbers normalization(RationalNumbers &value);
	friend int CommonDenominator(int num, int den);


	/******************************define comparison oveload routines**************************/
	friend bool operator <(RationalNumbers &value1, RationalNumbers &value2);
	friend bool operator >(RationalNumbers &value1, RationalNumbers &value2);
	friend bool operator ==(RationalNumbers &value1, RationalNumbers &value2);

	/******************************define opearator oveload routines*******************************/
	friend RationalNumbers operator +(RationalNumbers &value1, RationalNumbers &value2);
	friend RationalNumbers operator -(RationalNumbers &value1, RationalNumbers &value2);
	friend RationalNumbers operator *(RationalNumbers &value1, RationalNumbers &value2);
	friend RationalNumbers operator /(RationalNumbers &value1, RationalNumbers &value2);
	friend RationalNumbers operator -(RationalNumbers &value1);
	
	friend RationalNumbers operator >>(istream &input, RationalNumbers &value3);
	friend ostream& operator <<(ostream &output, RationalNumbers &value3);
	
};

#endif // end of ifnot defined statement