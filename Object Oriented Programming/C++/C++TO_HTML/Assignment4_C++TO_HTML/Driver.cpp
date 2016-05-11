#include <iostream>
#include <conio.h>
#include "HTML.h"
using namespace std;

string cppFile,htmlFile;
bool start = true;

int main()
	{
		HTML obj;
	while (start)
	{
		cppFile = obj.getCppFileName();
		htmlFile = obj.getHtmlFileName();
		obj.seekAndDestroy(cppFile, htmlFile);
		start = obj.shouldIContinue();


	}

	return 0;
}