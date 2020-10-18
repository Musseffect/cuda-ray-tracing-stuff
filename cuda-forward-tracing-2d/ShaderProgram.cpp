#include "ShaderProgram.h"




void ShaderProgram::destroy(){
	glDeleteProgram(program);
	program = 0;
}
std::string ShaderProgram::loadShader(const std::string& fileName){
	std::ifstream file;
	file.open((fileName).c_str());

	std::string output;
	std::string line;

	if (file.is_open()){
		while (file.good()){
			getline(file, line);
			output.append(line + "\n");
		}
	}
	else
		printf("Error: Failed to load shader %s\n", fileName.c_str());
	file.close();
	return output;
}
ShaderProgram::ShaderProgram(){
	program = 0;
}
void ShaderProgram::printLogShader(int shader){
	GLint logSize = 0;
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logSize);
	std::vector<GLchar> errorLog(logSize);
	glGetShaderInfoLog(shader, logSize, &logSize, &errorLog[0]);
	printf("Shader log:\n%s\n", &errorLog[0]);
}
inline void ShaderProgram::printActiveAttributes(){
	GLint maxLength, nAttribs;
	glGetProgramiv(program, GL_ACTIVE_ATTRIBUTES,
		&nAttribs);
	glGetProgramiv(program, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH,
		&maxLength);
	GLchar * name = new GLchar[maxLength];
	GLint written, size, location;
	GLenum type;
	printf(" Index | Name\n");
	printf("------------------------------------------------\n");
	for (int i = 0; i < nAttribs; i++){
		glGetActiveAttrib(program, i, maxLength, &written,
			&size, &type, name);
		location = glGetAttribLocation(program, name);
		printf(" %-5d | %s\n", location, name);
	}
	delete[]name;
}
bool ShaderProgram::loadShaderProgram(const char* vert, const char * frag){
	destroy();
	int vertex = glCreateShader(GL_VERTEX_SHADER);
	if (vertex == 0)
		return false;
	std::string t = loadShader(vert);
	GLint d = t.length();
	assert(d != 0);
	const GLchar* s = t.c_str();
	glShaderSource(vertex, 1, &s, &d);
	glCompileShader(vertex);

	int params = GL_FALSE;
	glGetShaderiv(vertex, GL_COMPILE_STATUS, &params);
	if (!params){
		printf("ERROR: GL shader index %i did not compile, filename:%s \n", vertex, vert);
		printLogShader(vertex);
		glDeleteShader(vertex);
		return false;
	}

	int fragment = glCreateShader(GL_FRAGMENT_SHADER);
	if (fragment == 0)
		return 0;
	t = loadShader(frag);
	d = t.length();
	assert(d != 0);
	const GLchar* r = t.c_str();
	glShaderSource(fragment, 1, &r, &d);
	glCompileShader(fragment);
	params = GL_FALSE;
	glGetShaderiv(fragment, GL_COMPILE_STATUS, &params);
	if (!params){
		printf("ERROR: GL shader index %i did not compile, filename:%s\n", fragment, frag);
		printLogShader(fragment);
		glDeleteShader(fragment);
		return false;
	}
	program = glCreateProgram();

	glAttachShader(program, vertex);
	glAttachShader(program, fragment);
	glLinkProgram(program);
	params = GL_FALSE;
	glDeleteShader(vertex);
	glDeleteShader(fragment);
	glGetProgramiv(program, GL_LINK_STATUS, &params);
	if (GL_TRUE != params){
		destroy();
		/*GLint logsize;
		glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logsize);
		char *log = new char[logsize];
		//__glewGetProgramInfoLog(program,logsize,NULL,log);
		glGetProgramInfoLog(program,logsize,&logsize,log);*/
		fprintf(stdout,
			"ERROR: could not link shader programm GL index %u ,filenames: %s , %s\n",
			program, vert, frag);
		return false;
	}
#ifdef DEBUG
	glValidateProgram(program);
	glGetProgramiv(program, GL_VALIDATE_STATUS, &params);
	if (GL_TRUE != params){
		/*GLint logsize;
		glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logsize);
		char *log = new char[logsize];*/
		//__glewGetProgramInfoLog(program,logsize,NULL,log);
		fprintf(stdout,
			"ERROR: could not link shader programm GL index %u\n",
			program);
		return false;
	}
#endif
	GLint count;

	GLint size; // size of the variable
	GLenum type; // type of the variable (float, vec3 or mat4, etc)

	GLint nameLength;
	glGetProgramiv(program, GL_ACTIVE_UNIFORMS,
		&count);
	glGetProgramiv(program, GL_ACTIVE_UNIFORM_MAX_LENGTH,
		&nameLength);
	GLchar *name = new GLchar[nameLength + 1]; // variable name in GLSL
	GLsizei length; // name length
	name[nameLength] = 0;
	printf("Active Uniforms: %d\n", count);
	if (!uniforms.empty())
		uniforms.clear();
	for (int i = 0; i < count; i++){
		glGetActiveUniform(program, (GLuint)i, nameLength, &length, &size, &type, name);
		int loc = glGetUniformLocation(program, name);
		uniforms[std::string(name)] = loc;
		//printf("Uniform #%d Type: %u Name: %s\n", i, type, name);
	}
	delete[]name;
	return true;
}
void ShaderProgram::link(){
	glLinkProgram(program);

	int params = GL_FALSE;
	glGetProgramiv(program, GL_LINK_STATUS, &params);
	if (GL_TRUE != params){
		destroy();
		/*GLint logsize;
		glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logsize);
		char *log = new char[logsize];
		//__glewGetProgramInfoLog(program,logsize,NULL,log);
		glGetProgramInfoLog(program,logsize,&logsize,log);*/
		fprintf(stdout,
			"ERROR: could not link shader programm GL index %u\n",
			program);
		return;
	}
}
inline void ShaderProgram::printActiveUniforms(){
	if (program != 0){
		GLint maxLength, nAttribs;
		glGetProgramiv(program, GL_ACTIVE_UNIFORMS,
			&nAttribs);
		glGetProgramiv(program, GL_ACTIVE_UNIFORM_MAX_LENGTH,
			&maxLength);
		GLchar * name = new GLchar[maxLength];
		GLint written, size, location;
		GLenum type;
		printf(" Index | Name\n");
		printf("------------------------------------------------\n");
		for (int i = 0; i < nAttribs; i++){
			glGetActiveUniform(program, i, maxLength, &written,
				&size, &type, name);
			location = glGetUniformLocation(program, name);
			printf(" %-5d | %s\n", location, name);
		}
		delete[]name;
	}
}
int ShaderProgram::getProgram(){
	return program;
}
void ShaderProgram::bindAttribLocation(GLint location, const char * name){
	glBindAttribLocation(program, location, name);
}
int ShaderProgram::getUniformLocation(const char* name){
	std::map<std::string, int>::iterator iter = uniforms.find(name);
	if (iter != uniforms.end())
		return iter->second;
	return -1;
}
int ShaderProgram::getAttribLocation(const char* name){
	return glGetAttribLocation(program, name);
}
int ShaderProgram::getFragDataLocation(const char* name){
	return glGetFragDataLocation(program, name);
}
void ShaderProgram::bindFragDataLocation(GLuint location, const char * name){
	glBindFragDataLocation(program, location, name);
}
void ShaderProgram::bind(){
	glUseProgram(program);
}
void ShaderProgram::unbind(){
	glUseProgram(0);
}
ShaderProgram::~ShaderProgram(){
	glDeleteProgram(program);
}