#include <iostream>
#include <conio.h>
#include "RationalNumbers.h" // Include My Rational Number Header file

using namespace std;

RationalNumbers::RationalNumbers()
{
	this->numerator = 0;
	this->denominator = 1;
}

/*********************************Constructor 1*************************************/

RationalNumbers::RationalNumbers(int num, int den)
{
	numerator = num;
	denominator = den;
}
/*********************************End of Constructor 1 ******************************/

/*********************************Constructor 2*************************************/

RationalNumbers::RationalNumbers(int number)
{
	numerator = number;
	denominator = 1;
}
/*********************************End of Constructor 2 ******************************/

RationalNumbers::~RationalNumbers(void)
{

}

/*********************Greatest Common Denominator (Internet Code)*****************************/
int CommonDenominator(int num, int den)
{
	int commonDenominator;
	if (den == 0)
	{
		return num;
	}
	else
	{
		commonDenominator = CommonDenominator(den, (num%den));
		if (commonDenominator < 0)
		{
			return  -commonDenominator;
		}
		else
		{
			return commonDenominator;
		}
	}
}
/************************Normailzation*******************/
RationalNumbers normalization(RationalNumbers &value)
{
	int num = value.numerator;
	int den = value.denominator;
	RationalNumbers normalizedValue;
	
	if (den < 0)
	{
		if (num < 0)
		{
			value.numerator = -num;
			value.denominator = -den;
		}
		else
		{
			value.denominator = -den;
		}
	}
	
	int greatestCommonDenominaotr = CommonDenominator(value.numerator, value.denominator);
	
	value.numerator /= greatestCommonDenominaotr;
	value.denominator /= greatestCommonDenominaotr;

	normalizedValue.numerator = value.numerator;
	normalizedValue.denominator = value.denominator;

	return normalizedValue;
}

/***********************************COMPARISON OVERLOAD ROUTINES IMPLEMENTATIONS*********************************/

bool operator <(RationalNumbers &value1, RationalNumbers &value2)
{
	if ((value1.numerator * value2.denominator) < (value1.denominator * value2.numerator))
	{
		return true;
	}
	else
	{
		return false;
	}
}

bool operator >(RationalNumbers &value1, RationalNumbers &value2)
{
	if ((value1.numerator * value2.denominator) > (value1.denominator * value2.numerator))
	{
		return true;
	}
	else
	{
		return false;
	}
}

bool operator ==(RationalNumbers &value1, RationalNumbers &value2)
{
	if ((value1.numerator * value2.denominator) == (value1.denominator * value2.numerator))
	{
		return true;
	}
	else
	{
		return false;
	}
}

/*******************************END OF VCOMPARISON OVERLOAD ROUTINES IMPLEMENTATIONS*********************************/


/***********************************OPERATOR OVERLOAD ROUTINES IMPLEMENTATIONS*********************************/
RationalNumbers operator +(RationalNumbers &value1, RationalNumbers &value2)
{
	RationalNumbers leftObj;
	RationalNumbers rightObj;
	RationalNumbers result;
	if (value1.denominator == value2.denominator)
	{
		result.denominator = value1.denominator;
		result.numerator = value1.numerator + value2.numerator;

		result = normalization(result);
		
	}
	else
	{
		leftObj.numerator = value1.numerator * value2.denominator;
		leftObj.denominator = value1.denominator * value2.denominator;
		rightObj.numerator = value2.numerator * value1.denominator;
		rightObj.denominator = value2.denominator * value1.denominator;

		result.numerator = leftObj.numerator + rightObj.numerator;
		result.denominator = leftObj.denominator;

		result = normalization(result);
		
	}
	return result;
}
RationalNumbers operator -(RationalNumbers &value1, RationalNumbers &value2)
{

	RationalNumbers leftObj;
	RationalNumbers rightObj;
	RationalNumbers result;
	if (value1.denominator == value2.denominator)
	{
		result.denominator = value1.denominator;

		if (value1.numerator > value2.numerator) // to prevent negative results
		{
			result.numerator = value1.numerator - value2.numerator;

			result = normalization(result);
			
		}
		else
		{
			result.numerator = value2.numerator - value1.numerator;
			result = normalization(result);
			
		}
		
	}
	else
	{
		leftObj.numerator = value1.numerator * value2.denominator;
		leftObj.denominator = value1.denominator * value2.denominator;
		rightObj.numerator = value2.numerator * value1.denominator;
		rightObj.denominator = value2.denominator * value1.denominator;
		result.denominator = leftObj.denominator;

		if (leftObj.numerator > rightObj.numerator)// to prevent negative results
		{
			result.numerator = leftObj.numerator - rightObj.numerator;
			result = normalization(result);
		
		}
		else
		{
			result.numerator = rightObj.numerator - leftObj.numerator;
			result = normalization(result);
			
		}
		
	}
	return result;
}
RationalNumbers operator *(RationalNumbers &value1, RationalNumbers &value2)
{

	RationalNumbers result;
	result.numerator = value1.numerator * value2.numerator;
	result.denominator = value1.denominator* value2.denominator;
	result = normalization(result);
	
	return result;

}
RationalNumbers operator /(RationalNumbers &value1, RationalNumbers &value2) 
{
	RationalNumbers result;
	result.numerator = value1.numerator * value2.denominator;
	result.denominator = value1.denominator* value2.numerator;
	result = normalization(result);

	return result;
}
/*********************************** IOSTREAM OVERLOAD ROUTINES IMPLEMENTATIONS*********************************/
ostream& operator <<(ostream& output, RationalNumbers &value3)
{
	int num;
	int den;
	num = value3.numerator;
	den = value3.denominator;
	output << num << '/' << den;
	return output;
}

RationalNumbers operator >>(istream& input, RationalNumbers &value3)
{


	int num;
	int den;
	char fractionSymbol;
	
	cout << "Enter numerator: ";
	input >> num;
	cout << "Enter faction symbol: ";
	input >> fractionSymbol;
	if (fractionSymbol == '/')
	{
		cout << "Enter Denominator: ";
		input >> den;
	}
	else
	{
		den = 1;
	}

	value3.numerator = num;
	value3.denominator = den;
	
	value3 = normalization(value3);
	return value3;
}
