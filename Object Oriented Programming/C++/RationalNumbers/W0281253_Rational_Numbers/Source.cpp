#include <iostream>
#include <conio.h>
#include "RationalNumbers.h"


using namespace std;

int main()
{
	int choice;
	RationalNumbers leftObject;
	RationalNumbers rightObject;
	RationalNumbers Result;
	bool comparison, done=false;
	char start;
	cout << "Welcome to The Ractional Number Program" <<endl;
	cout << "Your Options are as Follows"<<endl;

	while (done == false)
	{
		cout << "___________________________________________" << endl;
		cout << "| 1 = + | 2 = - | 3 = * | 4 = / | 5= <     |" << endl;
		cout << "___________________________________________" << endl;
		cout << "| 6 = > | 7 = (==) |-----------------      |" << endl;
		cout << "___________________________________________" << endl;
		cout << " " << endl;
		cout << " " << endl;
		cout << "Enter a Choice: ";
		cin >> choice;
		cout << "--------------------------------------------------" << endl;
		cout << "Enter left object" << endl;
		cin >> leftObject;
		cout << "---------------------------------------------------" << endl;
		cout << "Enter right object" << endl;
		cin >> rightObject;
		switch (choice)
		{
		case 1:
			Result = leftObject + rightObject;
			cout << "The Sum is: " << Result;
			break;
		case 2:
			Result = leftObject - rightObject;
			cout << "The Result is: " << Result;
			break;
		case 3:
			Result = leftObject * rightObject;
			cout << "The Product is: " << Result;
			break;
		case 4:
			Result = leftObject / rightObject;
			cout << "The Result is: " << Result;
			break;
		case 5:
			comparison = leftObject < rightObject;
			if (comparison == true)
			{
				cout << leftObject << " is less than " << rightObject;
				break;
			}
			else
			{
				cout << leftObject << " is NOT less than " << rightObject;
				break;
			}
		case 6:
			comparison = leftObject > rightObject;
			if (comparison == true)
			{
				cout << leftObject << " is greater than " << rightObject;
				break;
			}
			else
			{
				cout << leftObject << " is NOT greater than " << rightObject;
				break;
			}
		case 7:
			comparison = leftObject == rightObject;
			if (comparison == true)
			{
				cout << leftObject << " is equal to " << rightObject;
				break;
			}
			else
			{
				cout << leftObject << " is NOT equal to " << rightObject;
				break;
			}
		default:
			cout << "ERROR ENTER A VALID CHOICE";
			break;
		}

		cout << " " << endl;
		cout << " " << endl;

		cout << "DO YOU WANT TO CONTINUE Y/N: ";
		cin >> start;

		if (start == 'y')
		{
			done = false;
		}
		else
		{
			done = true;
		}
	}
	_getch();
	return 0;
}