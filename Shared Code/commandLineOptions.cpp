#include "commandLineOptions.h"



void CommandLineOptions::init(int argc, _TCHAR ** argv)
{
	for (int i = 0; i < argc; i++)
	{
		if (argv[i] != NULL)
		{
			if (argv[i][0] == '-')
			{
				if (i == argc - 1)
					continue;
				map[TString(argv[i])] = TString(argv[i + 1]);
			}
		}
	}
}
bool CommandLineOptions::exist(TString option)
{
	if (map.find(option) == map.end())
		return false;
	return true;
}
TString CommandLineOptions::getValue(TString option)
{
	return map[option];
}