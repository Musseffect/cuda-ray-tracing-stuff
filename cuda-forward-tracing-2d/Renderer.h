#pragma once
#pragma comment(lib,"glfw3dll.lib")
#pragma comment(lib,"glew32s.lib")
#pragma comment(lib,"FreeImage.lib")
#pragma comment(lib, "OPENGL32")


#define GLFW_DLL
#define GLEW_STATIC

#include "../Shared Code/imgui/imgui.h"
#include "../Shared Code/imgui/imgui_impl_glfw.h"
#include "../Shared Code/imgui/imgui_impl_opengl3.h"

#include <gl\glew.h>

#include <windows.h>
#include <glfw v3.2\glfw3.h>
#include <FreeImage3180\FreeImage.h>
#include "ShaderProgram.h"
#include "CudaFunctions.cuh"
#include<string>
#include <vector>

void newGLCheckError(const char *filename, const int line);
#define CheckGl() 	newGLCheckError(__FILE__, __LINE__);

static void glfw_error_callback(int error, const char* description);

struct ImgSizePos{
	float w;
	float h;
	float x;
	float y;
};

ImgSizePos getCorrectSize(int screenW, int screenH, int imgW, int imgH);




class Renderer{
	struct cudaGraphicsResource* resourceVBO;
	int width;
	int height;
	int rayBatchSize;
	int rayBatchCount;
	int rays;
	int sleepAmount;
	float exposure;
	int size;
	int w;
	int h;
	float timeFrame;
	float dt;
	int frameRate;
	int frames;
	CudaScene cudaScene;
	std::vector<Object> objects;

	int* dev_rays;
	VBOInfo* dev_vbo = 0;
	RayInfo* dev_rayInfo = 0;
	curandState_t* dev_states = 0;
	enum{
		CIRCLE_TESSELATION = 36
	};
	//gl resources
	enum TEXTURE{
		OFFSCREEN = 0,
		BUFFER1 = 1,
		TEXTURECOUNT = 2
	};
	unsigned int textures[TEXTURECOUNT];
	enum FBO{
		FBO1 = 0,
		FBO2 = 1,
		FBOCOUNT = 2
	};
	enum ShaderEnum{
		DrawBuffer = 0,
		LineShader = 1,
		DrawToScreen = 2,
		DrawShape = 3,
		SHADERCOUNT = 4
	};
	enum VAO{
		LineVao = 0,
		ScreenGeomVao = 1,
		LineShapeVao = 2,
		CircleShapeVao = 3,
		VAOCOUNT = 4
	};
	enum VBO{
		LightInfoVBO = 0,
		ScreenGeomVBO = 1,
		LineVBO = 2,
		CircleVBO = 3,
		VBOCOUNT = 4
	};
	ShaderProgram programs[SHADERCOUNT];
	unsigned int fbos[FBOCOUNT];
	unsigned int vaos[VAOCOUNT];
	unsigned int vbos[VBOCOUNT];
	void init();//Done
	void initScene();//Done
	void renderLineFrame(float time);
	void renderPulseFrame(float time, float dt);
	/*
	animation rendering
	*/
	//render full line animation
	void saveLineFrames(std::string filename, int framerate, int frames);
	//render pulse animation
	void savePulseFrames(std::string filename, int framerate, int frames);
	/*
	single frame rendering
	*/
	//render full lines
	void renderLines(float time);
	//render pulses
	void renderPulses(float time, float dt);
	void postProcess();
	void saveFrame(std::string filename);
public:
	Renderer();

	void start();//Done
	void setupFrame();
	void initLineBuffer();
	void loadScene();
	void initCudaScene(const SceneDescription& scene);//Done

	~Renderer();
};