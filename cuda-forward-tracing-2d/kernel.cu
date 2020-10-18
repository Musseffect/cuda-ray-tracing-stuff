
#include "..\Shared Code\commandLineOptions.h"
#include "Renderer.h"

int main(int argc, _TCHAR* argv[]){
	CommandLineOptions o;
	o.init(argc, argv);

	Renderer renderer;
	renderer.start();
	return -1;
}
