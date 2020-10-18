#pragma once
#include <string>
#include<fstream>
#include <assert.h>
#include <map>
#include <vector>
#define GLEW_STATIC
#include <gl\glew.h>

class ShaderProgram{
	int program;
	void destroy();
	static std::string loadShader(const std::string& fileName);
public:
	std::map<std::string, int> uniforms;
	ShaderProgram();
	void printLogShader(int shader);
	inline void printActiveAttributes();
	bool loadShaderProgram(const char* vert, const char * frag);
	void link();
	inline void printActiveUniforms();
	int getProgram();
	void bindAttribLocation(GLint location, const char * name);
	int getUniformLocation(const char* name);
	int getAttribLocation(const char* name);
	int getFragDataLocation(const char* name);
	void bindFragDataLocation(GLuint location, const char * name);
	void bind();
	void unbind();
	~ShaderProgram();
};

