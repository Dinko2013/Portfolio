#pragma once

#include <iostream>
#include <fstream>
#include <conio.h>
#include <regex>

using namespace std;
class HTML
{

public:
	string getCppFileName();
	string getHtmlFileName();
	void seekAndDestroy(string cpp_file_name, string html_file_name);
	bool shouldIContinue();
};



