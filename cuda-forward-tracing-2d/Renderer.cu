#include "Renderer.h"
#include "cuda_gl_interop.h"
#include <iostream>
#include <time.h>



#ifdef DEBUG
#define HANDLE_ERROR(x){\
	cudaError_t cudaStatus = (x); \
if (cudaStatus != cudaSuccess){\
	fprintf(stdout, ": %s\n", cudaGetErrorString(cudaStatus)); \
	system("Pause"); \
	exit(1); \
} \
}
#else
#define HANDLE_ERROR(x) x
#endif



void glfw_error_callback(int error, const char* description){
	fprintf(stderr, "Glfw Error %d: %s\n", error, description);
}

void newGLCheckError(const char *filename, const int line){
	GLenum err;
	char str[64];

	for (int i = 0; i < 5; i++){
		if ((err = glGetError()) != GL_NO_ERROR){
			switch (err){
			case GL_INVALID_ENUM:
				strcpy_s(str, "GL_INVALID_ENUM");
				break;
			case GL_INVALID_VALUE:
				strcpy_s(str, "GL_INVALID_VALUE");
				break;
			case GL_INVALID_OPERATION:
				strcpy_s(str, "GL_INVALID_OPERATION");
				break;
			case GL_STACK_OVERFLOW:
				strcpy_s(str, "GL_STACK_OVERFLOW");
				break;
			case GL_STACK_UNDERFLOW:
				strcpy_s(str, "GL_STACK_UNDERFLOW");
				break;
			case GL_OUT_OF_MEMORY:
				strcpy_s(str, "GL_OUT_OF_MEMORY");
				break;
				/*case GL_INVALID_FRAMEBUFFER_OPERATION:
				strcpy_s(str, "GL_INVALID_FRAMEBUFFER_OPERATION");
				break;*/
			default: break;
			}
			printf("GL error %ss %#x in file %s in line %d \n", str, err, filename, line);
		}
		else break;
	}
}


ImgSizePos getCorrectSize(int screenW, int screenH, int imgW, int imgH){
	float screenRatio = float(screenW) / float(screenH);
	float imageRatio = float(imgW) / float(imgH);
	ImgSizePos sizePos;
	if (imageRatio > screenRatio){
		sizePos.w = 1.0f;
		sizePos.h = screenRatio / imageRatio;
		sizePos.x = 0.0f;
		sizePos.y = 0.0f;
	}
	else{
		sizePos.w = imageRatio / screenRatio;
		sizePos.h = 1.0f;
		sizePos.x = 0.0f;
		sizePos.y = 0.0f;
	}
	return sizePos;
}
inline float clamp(float x){ return x < 0.0f ? 0.0f : x > 1.0f ? 1.0f : x; }
inline int toInt(float x){ return int(clamp(x) * 255 + .5); }


void Renderer::postProcess(){
	glBindFramebuffer(GL_FRAMEBUFFER, fbos[FBO::FBO2]);
	glViewport(0, 0, width, height);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, textures[TEXTURE::BUFFER1]);

	glBindVertexArray(vaos[VAO::ScreenGeomVao]);
	programs[ShaderEnum::DrawBuffer].bind();
	glUniform1f(programs[ShaderEnum::DrawBuffer].getUniformLocation("exposure"), glm::pow(2.0f, exposure));
	glUniform1f(programs[ShaderEnum::DrawBuffer].getUniformLocation("rays"), float(rays));
	glUniform1i(programs[ShaderEnum::DrawBuffer].getUniformLocation("buffer"), 0);
	glDrawArrays(GL_TRIANGLES, 0, 6);

	glEnable(GL_LINE_SMOOTH);
	programs[ShaderEnum::DrawShape].bind();
	glUniform1f(programs[ShaderEnum::DrawShape].getUniformLocation("aspectRatio"), float(width) / height);
	for (int i = 0; i < objects.size(); i++){
		glUniformMatrix3fv(programs[ShaderEnum::DrawShape].getUniformLocation("matrix"), 1, GL_FALSE, glm::value_ptr(objects[i].t.inv));
		if (objects[i].objectType == 0){
			glBindVertexArray(vaos[VAO::LineShapeVao]);
			glDrawArrays(GL_LINES, 0, 2);
		}
		else if (objects[i].objectType == 1){
			glBindVertexArray(vaos[VAO::CircleShapeVao]);
			glDrawArrays(GL_LINE_LOOP, 0, CIRCLE_TESSELATION);
		}
	}
}
void Renderer::saveFrame(std::string filename){
	postProcess();
	std::vector<float3> data(width * height);
	glBindTexture(GL_TEXTURE_2D, textures[TEXTURE::OFFSCREEN]);
	glGetTexImage(GL_TEXTURE_2D, 0, GL_RGB, GL_FLOAT, &data[0]);
	FreeImage_Initialise();
	FIBITMAP *bitmap = FreeImage_Allocate(width, height, 24);
	for (int j = 0; j < height; j++)
	for (int i = 0; i < width; i++){
		RGBQUAD rgb;
		float3 frgb = data[i + j*width];
		rgb.rgbRed = (BYTE)toInt(frgb.x);
		rgb.rgbGreen = (BYTE)toInt(frgb.y);
		rgb.rgbBlue = (BYTE)toInt(frgb.z);
		FreeImage_SetPixelColor(bitmap, i, j, &rgb);
	}
	filename += ".png";
	FreeImage_Save(FREE_IMAGE_FORMAT::FIF_PNG, bitmap, filename.c_str());
	FreeImage_Unload(bitmap);
	FreeImage_DeInitialise();
}

void Renderer::saveLineFrames(std::string filename, int framerate, int frames){
	initLineBuffer();
	setupFrame();
	for (int i = 0; i < frames; i++){
		printf("Frame : %d\n", i);
		HANDLE_ERROR(cudaMemset(dev_rayInfo, 0x00, rayBatchSize * sizeof(RayInfo)));
		HANDLE_ERROR(cudaMemset(dev_rays, 0x00, sizeof(int)));
		float _time = float(i) / framerate;
		renderLineFrame(_time);
		saveFrame(filename + std::to_string(i + 1));
	}
	HANDLE_ERROR(cudaGraphicsUnregisterResource(resourceVBO));
	cudaFree(dev_rayInfo);
	cudaFree(dev_states);
}
//render pulse animation
void Renderer::savePulseFrames(std::string filename, int framerate, int frames){
	initLineBuffer();
	setupFrame();
	for (int i = 0; i < frames; i++){
		printf("Frame : %d\n", i);
		HANDLE_ERROR(cudaMemset(dev_rayInfo, 0x00, rayBatchSize * sizeof(RayInfo)));
		HANDLE_ERROR(cudaMemset(dev_rays, 0x00, sizeof(int)));
		float _time = float(i) / framerate;
		renderPulseFrame(_time, dt);
		saveFrame(filename + std::to_string(i + 1));
	}
	HANDLE_ERROR(cudaGraphicsUnregisterResource(resourceVBO));
	cudaFree(dev_rayInfo);
	cudaFree(dev_states);
}
/*
single frame rendering
*/
void Renderer::renderLineFrame(float time){
	int seed = rand();
	dim3 block(64, 1, 1);
	dim3 grid((int)ceil(float(rayBatchSize) / block.x), 1, 1);
	curandInitKernel << <grid, block >> >(dev_states, seed, rayBatchSize);
	HANDLE_ERROR(cudaDeviceSynchronize());
	HANDLE_ERROR(cudaGetLastError());

	glBindFramebuffer(GL_FRAMEBUFFER, fbos[FBO::FBO1]);
	glViewport(0, 0, width, height);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	for (int i = 0; i < rayBatchCount; i++){
		//run cuda 
		size_t num_bytes = 0;
		HANDLE_ERROR(cudaGraphicsMapResources(1, &resourceVBO, 0));
		HANDLE_ERROR(cudaGraphicsResourceGetMappedPointer((void **)&dev_vbo,
			&num_bytes, resourceVBO));
		kernelLine << < grid, block >> >(dev_rayInfo, dev_vbo, cudaScene, dev_states, dev_rays, rayBatchSize, time);
		HANDLE_ERROR(cudaDeviceSynchronize());
		HANDLE_ERROR(cudaGetLastError());
		if (i != rayBatchCount - 1){
			printf("\rProgress %d    ", i + 1);
			Sleep(sleepAmount);
		}
		HANDLE_ERROR(cudaGraphicsUnmapResources(1, &resourceVBO, 0));

		glLineWidth((float)size);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		//glEnable(GL_LINE_SMOOTH);
		glEnable(GL_BLEND);
		glBlendFunc(GL_ONE, GL_ONE);
		glBlendEquation(GL_FUNC_ADD);
		programs[1].bind();
		glUniform1f(programs[1].getUniformLocation("aspectRatio"), float(width) / height);
		glUniform2f(programs[1].getUniformLocation("screenSize"), (float)width, (float)height);
		glBindVertexArray(vaos[VAO::LineVao]);
		glDrawArrays(GL_LINES, 0, rayBatchSize * 2);
	}
	HANDLE_ERROR(cudaMemcpy((void*)&rays, dev_rays, sizeof(int), cudaMemcpyDeviceToHost));
	printf("\n");
}
void Renderer::renderPulseFrame(float time, float dt){
	int seed = rand();
	dim3 block(64, 1, 1);
	dim3 grid((int)ceil(float(rayBatchSize) / block.x), 1, 1);
	curandInitKernel << <grid, block >> >(dev_states, seed, rayBatchSize);

	glBindFramebuffer(GL_FRAMEBUFFER, fbos[FBO::FBO1]);
	glViewport(0, 0, width, height);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);

	HANDLE_ERROR(cudaDeviceSynchronize());
	HANDLE_ERROR(cudaGetLastError());
	for (int i = 0; i < rayBatchCount; i++){
		//run cuda 
		size_t num_bytes = 0;
		HANDLE_ERROR(cudaGraphicsMapResources(1, &resourceVBO, 0));
		HANDLE_ERROR(cudaGraphicsResourceGetMappedPointer((void **)&dev_vbo,
			&num_bytes, resourceVBO));
		kernelLinePulse << < grid, block >> >(dev_rayInfo, dev_vbo, cudaScene, dev_states, dev_rays, rayBatchSize, time, dt);
		HANDLE_ERROR(cudaDeviceSynchronize());
		HANDLE_ERROR(cudaGetLastError());
		if (i != rayBatchCount - 1){
			printf("\rProgress %d    ", i + 1);
			Sleep(sleepAmount);
		}
		HANDLE_ERROR(cudaGraphicsUnmapResources(1, &resourceVBO, 0));

		glLineWidth((float)size);
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		//glEnable(GL_LINE_SMOOTH);
		glEnable(GL_BLEND);
		glBlendFunc(GL_ONE, GL_ONE);
		glBlendEquation(GL_FUNC_ADD);
		programs[1].bind();
		glUniform1f(programs[1].getUniformLocation("aspectRatio"), float(width) / height);
		glUniform2f(programs[1].getUniformLocation("screenSize"), (float)width, (float)height);
		glBindVertexArray(vaos[VAO::LineVao]);
		glDrawArrays(GL_LINES, 0, rayBatchSize * 2);
	}
	HANDLE_ERROR(cudaMemcpy((void*)&rays, dev_rays, sizeof(int), cudaMemcpyDeviceToHost));
	printf("\n");
}
//render full lines
void Renderer::renderLines(float time){
	initLineBuffer();
	setupFrame();
	renderLineFrame(time);
	HANDLE_ERROR(cudaGraphicsUnregisterResource(resourceVBO));
	cudaFree(dev_rayInfo);
	cudaFree(dev_states);
}

//render pulses
void Renderer::renderPulses(float time, float dt){
	initLineBuffer();
	setupFrame();
	renderPulseFrame(time, dt);
	HANDLE_ERROR(cudaGraphicsUnregisterResource(resourceVBO));
	cudaFree(dev_rayInfo);
	cudaFree(dev_states);
}


Renderer::Renderer(){
	cudaScene.lights = NULL;
	cudaScene.objects = NULL;
	cudaScene.materials = NULL;
}
Renderer::~Renderer(){
	glDeleteTextures(TEXTURECOUNT, textures);
	glDeleteFramebuffers(FBOCOUNT, fbos);

	cudaFree(dev_rays);
	cudaFree(cudaScene.lights);
	cudaFree(cudaScene.objects);
	cudaFree(cudaScene.materials);
}
void Renderer::start(){
	glfwSetErrorCallback(glfw_error_callback);
	if (!glfwInit())
		return;
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	GLFWwindow* window = glfwCreateWindow(1024, 1024, "Cuda forward tracing 2d", NULL, NULL);
	if (window == NULL){
		glfwTerminate();
		return;
	}
	glfwMakeContextCurrent(window);
	glewExperimental = GL_TRUE;
	GLenum glew_status = glewInit();
	if (glew_status != GLEW_OK){
		fprintf(stdout, "Error: %s\n", glewGetErrorString(glew_status));
		return;
	}
	glGetError();
	glfwSwapInterval(1);

	IMGUI_CHECKVERSION();
	ImGui::CreateContext();
	ImGuiIO& io = ImGui::GetIO();

	const char* glsl_version = "#version 330";
	ImGui::StyleColorsDark();
	ImGui_ImplGlfw_InitForOpenGL(window, true);
	ImGui_ImplOpenGL3_Init(glsl_version);

	init();
	initScene();
	exposure = 1.0f;
	rayBatchSize = 2048;
	rayBatchCount = 100;
	sleepAmount = 20;
	size = 1;
	timeFrame = 0.0;
	frameRate = 24;
	frames = 240;
	w = 1280;
	h = 720;
	dt = 100.0f;
	srand(time(NULL));

	char buf[64];
	memset(buf, 0x00, sizeof(char)* 64);
	while (!glfwWindowShouldClose(window)){
		glfwPollEvents();
		ImGui_ImplOpenGL3_NewFrame();
		ImGui_ImplGlfw_NewFrame();
		ImGui::NewFrame();
		{
			ImGui::Begin("main");
			ImGui::SliderFloat("exposure", &exposure, -100.0f, 100.0f);
			ImGui::DragInt("width", &w, 1.0f, 200, 1920);
			ImGui::DragInt("height", &h, 1.0f, 200, 1080);
			ImGui::DragInt("ray batch size", &rayBatchSize, 1.0f, 64, 8192);
			ImGui::DragInt("ray batch count", &rayBatchCount, 1.0f, 1, 10000);
			ImGui::DragFloat("time frame", &timeFrame, 0.1f, 0.0f, 1000.0f);
			ImGui::DragFloat("dt", &dt, 0.1f, 0.0f, 1000.0f);
			if (ImGui::Button("load scene")){
				loadScene();
			}
			if (ImGui::Button("render frame")){
				width = w;
				height = h;
				renderLines(timeFrame);
			}
			if (ImGui::Button("render frame pulse")){
				width = w;
				height = h;
				renderPulses(timeFrame, dt);
			}
			ImGui::End();
			//render fbo
			ImGui::Begin("anim");
			ImGui::DragInt("framerate", &frameRate, 1.0f, 1, 60);
			ImGui::DragInt("frames", &frames, 1.0f, 1, 10000);
			ImGui::InputText("filename", buf, IM_ARRAYSIZE(buf));
			if (ImGui::Button("render full line anim")){
				width = w;
				height = h;
				saveLineFrames(std::string(buf), frameRate, frames);
			}
			if (ImGui::Button("render pulse anim")){
				width = w;
				height = h;
				savePulseFrames(std::string(buf), frameRate, frames);
			}
			ImGui::End();
		}
		ImGui::Render();
		glfwMakeContextCurrent(window);

		int screenWidth, screenHeight;
		glfwGetFramebufferSize(window, &screenWidth, &screenHeight);

		postProcess();

		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glViewport(0, 0, screenWidth, screenHeight);
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		glClear(GL_COLOR_BUFFER_BIT);
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, textures[TEXTURE::OFFSCREEN]);
		programs[ShaderEnum::DrawToScreen].bind();
		ImgSizePos imgSizePos = getCorrectSize(screenWidth, screenHeight, width, height);
		glm::mat3 mvp = glm::mat3(1.0f);
		mvp = glm::translate(mvp, glm::vec2(imgSizePos.x, imgSizePos.y));
		mvp = glm::scale(mvp, glm::vec2(imgSizePos.w, imgSizePos.h));
		//mvp = glm::inverse(mvp);
		glBindVertexArray(vaos[VAO::ScreenGeomVao]);
		glUniform1i(programs[ShaderEnum::DrawToScreen].getUniformLocation("buffer"), 0);
		glUniformMatrix3fv(programs[ShaderEnum::DrawToScreen].getUniformLocation("mvp"), 1, GL_FALSE, glm::value_ptr(mvp));
		glDrawArrays(GL_TRIANGLES, 0, 6);
		programs[2].unbind();
		//!!
		ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

		glfwMakeContextCurrent(window);
		glfwSwapBuffers(window);
	}
	ImGui_ImplOpenGL3_Shutdown();
	ImGui_ImplGlfw_Shutdown();
	ImGui::DestroyContext();
	glfwDestroyWindow(window);
	glfwTerminate();
}

void Renderer::init(){
	const char* shaderNames[] = {
		"Shaders/drawBuffer.vert", "Shaders/drawBuffer.frag",
		"Shaders/lineShader.vert", "Shaders/lineShader.frag",
		"Shaders/drawScreen.vert", "Shaders/drawScreen.frag",
		"Shaders/drawShape.vert", "Shaders/drawShape.frag"
	};
	for (int i = 0; i < SHADERCOUNT; i++){
		if (!programs[i].loadShaderProgram(shaderNames[i * 2], shaderNames[i * 2 + 1])){
			printf("Error loading shader file.\n");
			system("pause");
			exit(1);
		}
	}
	//INIT FBO AND TEXURES
	glGenFramebuffers(FBOCOUNT, fbos);
	glGenTextures(TEXTURE::TEXTURECOUNT, textures);

	float white[3] = { 1.0f, 1.0f, 1.0f };
	width = 1;
	height = 1;
	glBindTexture(GL_TEXTURE_2D, textures[TEXTURE::BUFFER1]);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, width, height, 0, GL_RGB, GL_FLOAT, white);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);


	//create vaos and vbos
	glGenVertexArrays(VAOCOUNT, vaos);
	glGenBuffers(VBOCOUNT, vbos);

	glBindVertexArray(vaos[LineVao]);
	glBindBuffer(GL_ARRAY_BUFFER, vbos[LightInfoVBO]);
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(VBOInfo), 0);
	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(VBOInfo), (void *)(4 * sizeof(float)));
	glEnableVertexAttribArray(2);
	glVertexAttribPointer(2, 1, GL_FLOAT, GL_FALSE, sizeof(VBOInfo), (void *)(7 * sizeof(float)));

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);


	programs[LineShader].bindAttribLocation(0, "in_pos");
	programs[LineShader].bindAttribLocation(1, "in_color");
	programs[LineShader].bindAttribLocation(2, "in_angle");
	programs[LineShader].link();
	/*
	programs[PointShader].bindAttribLocation(0, "in_pos");
	programs[PointShader].bindAttribLocation(1, "in_color");
	programs[PointShader].bindAttribLocation(2, "in_angle");
	programs[PointShader].link();*/

	float fullscreenRect[] = { -1.0, -1.0
		, -1.0, 1.0
		, 1.0, 1.0
		, -1.0, -1.0
		, 1.0, 1.0
		, 1.0, -1.0
	};
	glBindVertexArray(vaos[ScreenGeomVao]);
	glBindBuffer(GL_ARRAY_BUFFER, vbos[VBO::ScreenGeomVBO]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)* 12, fullscreenRect, GL_STATIC_DRAW);

	programs[0].bindAttribLocation(0, "pos");
	programs[0].link();
	programs[2].bindAttribLocation(0, "pos");
	programs[2].link();
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);

	programs[DrawShape].bindAttribLocation(0, "in_pos");
	programs[DrawShape].link();

	glBindVertexArray(vaos[VAO::LineShapeVao]);
	glBindBuffer(GL_ARRAY_BUFFER, vbos[VBO::LineVBO]);
	float line[] = { 0.0f, 0.0f, 1.0f, 0.0f };
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)* 4, line, GL_STATIC_DRAW);
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);

	glBindVertexArray(vaos[VAO::CircleShapeVao]);
	glBindBuffer(GL_ARRAY_BUFFER, vbos[VBO::CircleVBO]);
	std::vector<float> circleVectors(CIRCLE_TESSELATION * 2);
	for (int i = 0; i < CIRCLE_TESSELATION; i++){
		circleVectors[i * 2] = glm::cos(i*glm::two_pi<float>() / CIRCLE_TESSELATION);
		circleVectors[i * 2 + 1] = glm::sin(i*glm::two_pi<float>() / CIRCLE_TESSELATION);
	}
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)* 2 * CIRCLE_TESSELATION, &circleVectors[0], GL_STATIC_DRAW);
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);

	CheckGl();

	HANDLE_ERROR(cudaMalloc((void**)&dev_rays, sizeof(int)));
}
void Renderer::initScene(){
	SceneDescription scene;
	Light light;
	light.lightType = _POINT;
	light.color = glm::vec3(1.0,1.,0.);
	light.angle = 0.0;
	light.t = createTransform(glm::vec2(0.0f, 0.0f), glm::radians(0.0f), glm::vec2(0.01f));
	scene.lights.push_back(light);

	initCudaScene(scene);
}

void Renderer::initCudaScene(const SceneDescription& scene){
	objects.clear();
	//could be null pointers
	cudaFree(cudaScene.lights);
	cudaFree(cudaScene.objects);
	cudaFree(cudaScene.materials);
	for (auto iter = scene.objects.begin(); iter != scene.objects.end(); ++iter){
		objects.push_back(*iter);
	}
	cudaScene.lightCount = scene.lights.size();
	cudaScene.matCount = scene.materials.size();
	cudaScene.objCount = scene.objects.size();
	cudaScene.minDepth = 3;
	cudaScene.maxDepth = 8;
	if (cudaScene.matCount>0)
		HANDLE_ERROR(cudaMalloc((void**)&(cudaScene.materials), cudaScene.matCount * sizeof(Material)));
	if (cudaScene.objCount>0)
		HANDLE_ERROR(cudaMalloc((void**)&(cudaScene.objects), cudaScene.objCount * sizeof(Object)));
	if (cudaScene.lightCount>0)
		HANDLE_ERROR(cudaMalloc((void**)&(cudaScene.lights), cudaScene.lightCount * sizeof(Light)));

	if (cudaScene.matCount>0)
		HANDLE_ERROR(cudaMemcpy(cudaScene.materials, scene.materials.data(), cudaScene.matCount * sizeof(Material), cudaMemcpyHostToDevice));
	if (cudaScene.objCount>0)
		HANDLE_ERROR(cudaMemcpy(cudaScene.objects, scene.objects.data(), cudaScene.objCount * sizeof(Object), cudaMemcpyHostToDevice));

	if (cudaScene.lightCount>0)
		HANDLE_ERROR(cudaMemcpy(cudaScene.lights, scene.lights.data(), cudaScene.lightCount * sizeof(Light), cudaMemcpyHostToDevice));
}
void Renderer::initLineBuffer(){
	glBindBuffer(GL_ARRAY_BUFFER, vbos[VBO::LightInfoVBO]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(VBOInfo)* rayBatchSize * 2, NULL, GL_DYNAMIC_DRAW);

	resourceVBO = NULL;
	HANDLE_ERROR(cudaGraphicsGLRegisterBuffer(&resourceVBO, vbos[VBO::LightInfoVBO], cudaGraphicsMapFlagsWriteDiscard));

}


void Renderer::setupFrame(){
	glBindTexture(GL_TEXTURE_2D, textures[TEXTURE::BUFFER1]);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, width, height, 0, GL_RGBA, GL_FLOAT, NULL);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	glBindTexture(GL_TEXTURE_2D, textures[TEXTURE::OFFSCREEN]);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, width, height, 0, GL_RGB, GL_FLOAT, NULL);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	glBindFramebuffer(GL_FRAMEBUFFER, fbos[FBO::FBO1]);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textures[TEXTURE::BUFFER1], 0);
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
		fprintf(stdout, "fbo1 attachement failed\n"); \
			system("pause"); \
			exit(1);
	}

	glBindFramebuffer(GL_FRAMEBUFFER, fbos[FBO::FBO2]);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textures[TEXTURE::OFFSCREEN], 0);
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
		fprintf(stdout, "fbo2 attachement failed\n"); \
			system("pause"); \
			exit(1);
	}

	//setup cuda

	HANDLE_ERROR(cudaMalloc((void**)&dev_rayInfo, rayBatchSize * sizeof(RayInfo)));
	HANDLE_ERROR(cudaMalloc((void**)&dev_states, rayBatchSize*sizeof(curandState_t)));
	HANDLE_ERROR(cudaMemset(dev_rayInfo, 0x00, rayBatchSize * sizeof(RayInfo)));
	HANDLE_ERROR(cudaMemset(dev_rays, 0x00, sizeof(int)));
}
void Renderer::loadScene(){
	throw "Not implemented";
}
