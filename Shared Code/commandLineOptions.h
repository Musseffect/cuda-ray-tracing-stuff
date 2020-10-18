#pragma once
#include <stdio.h>
#include <tchar.h>
#include <unordered_map>
#include <iostream>
#include <string>

#ifdef _UNICODE
typedef std::wstring TString;
#else
typedef std::string TString;
#endif

class CommandLineOptions{
	std::unordered_map<TString, TString> map;
public:
	void init(int argc, _TCHAR ** argv);
	bool exist(TString option);
	TString getValue(TString option);
};
