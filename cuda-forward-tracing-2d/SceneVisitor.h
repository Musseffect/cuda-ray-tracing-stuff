#pragma once
#ifdef USE_PARSER
#include "SceneGrammarVisitor.h"
#include "SceneParsing.h"
#endif


#ifdef USE_PARSER

static std::string constants[] = {
	"DIFFUSEREFL",
	"DIFFUSETRANS",
	"SPECULARGLASS",
	"SPECULARREFL",
	"SPECULARTRANS",

};
enum Constant{
	DIFFUSEREFL=0,
	DIFFUSETRANS=1,
	SPECULARGLASS=2,
	SPECULARREFL=3,
	MATERIAL_CONSTANT=4,
	FORWARD=5,
	BACK=6,
	BOTH=7,
	NORMAL_CONSTANT=8
};


struct Variable{
	Variable operator=(const Variable& b){
		return Variable();
	}
	Variable(const Variable& b){
	}
public:
	enum Type{
		FLOAT,
		MATERIAL,
		VEC2,
		COLOR,
		ID,
		MATERIAL_CONSTANT,
		VOID
	};
	Type type;
	void* value;
	Variable(){
		value = nullptr;
		type = VOID;
	}
	template<class T>
	T getValue();
	~Variable(){
		delete value;
	}
};
void line(vec2 p1, vec2 p2, int material,NormalType nt, SceneDescription *sceneDescription){
	Object obj;
	obj.objectType = 0;
	obj.normalType = nt;
	obj.materialType = material;
	obj.t = createTransform(p1, atan(p2.y - p1.y, p2.x - p1.x), vec2(glm::distance(p1, p2)));
	sceneDescription->objects.push_back(obj);
}
void circle(vec2 center, float r, int material, NormalType nt, SceneDescription *sceneDescription){
	Object obj;
	obj.objectType = 1;
	obj.normalType = nt;
	obj.materialType = material;
	obj.t = createTransform(center, 0.0f, glm::vec2(r));
	sceneDescription->objects.push_back(obj);
}
void pointLight(vec2 position, vec3 color, SceneDescription *sceneDescription){
	Light light;
	light.color = color;
	light.lightType = LightType::_POINT;
	light.t = createTransform(position, 0.0, glm::vec2(1.0f));
	sceneDescription->lights.push_back(light);
}
void pointDirLight(vec2 position, vec2 direction, vec3 color, SceneDescription *sceneDescription){
	Light light;
	light.color = color;
	light.lightType = LightType::POINTDIRECTIONAL;
	light.t = createTransform(position, glm::atan(direction.y, direction.x), glm::vec2(1.0f));
	sceneDescription->lights.push_back(light);
}
void pointAngLight(vec2 position, vec2 direction, float angle, vec3 color, SceneDescription *sceneDescription){
	Light light;
	light.color = color;
	light.lightType = LightType::POINTANGULAR;
	light.angle = angle;
	light.t = createTransform(position, glm::atan(direction.y, direction.x), glm::vec2(1.0f));
	sceneDescription->lights.push_back(light);
}
void circleLight(vec2 position, float radius, vec3 color, SceneDescription *sceneDescription){
	Light light;
	light.color = color;
	light.lightType = LightType::CIRCLE;
	light.t = createTransform(position, 0.0f, glm::vec2(radius));
	sceneDescription->lights.push_back(light);
}
void circleAngLight(vec2 position, float radius, float angle, vec3 color, SceneDescription *sceneDescription){
	Light light;
	light.color = color;
	light.lightType = LightType::CIRCLEANGULAR;
	light.angle = angle;
	light.t = createTransform(position, 0.0f, glm::vec2(radius));
	sceneDescription->lights.push_back(light);
}
void lineLight(vec2 pos1,vec2 pos2, vec3 color, SceneDescription *sceneDescription){
	Light light;
	light.color = color;
	light.lightType = LightType::LINE;
	light.t = createTransform(pos1, glm::atan(pos2.y - pos1.y, pos2.x - pos1.x), glm::vec2(1.0f));
	sceneDescription->lights.push_back(light);
}
void lineDirLight(vec2 pos1, vec2 pos2, vec3 color, SceneDescription *sceneDescription){
	Light light;
	light.color = color;
	light.lightType = LightType::LINEDIRECTIONAL;
	light.t = createTransform(pos1, glm::atan(pos2.y - pos1.y, pos2.x - pos1.x), glm::vec2(1.0f));
	sceneDescription->lights.push_back(light);
}

void material(vec3 r, vec3 t,vec3 b,vec3 c,MaterialType type, SceneDescription *sceneDescription){
	Material mat;
	mat.r = r;
	mat.t = t;
	mat.b = b;
	mat.c = c;
	mat.type = type;
	sceneDescription->materials.push_back(mat);
}

typedef void (*FuncPtr)(std::vector<Variable*> args);

void funcLine(std::vector<Variable*> args){
	static_assert(false,"NOT IMPLEMENTED");
	vec2 pos1;
	vec2 pos2;
	int material;
	NormalType nt;
	line(pos1,pos2,material,nt, SceneVisitor::sceneDescription);
}
void funcCircle(std::vector<Variable*> args){
	static_assert(false, "NOT IMPLEMENTED");
	vec2 position;
	float radius;
	int material;
	NormalType nt;
	circle(position, radius, material, nt, SceneVisitor::sceneDescription);
}
void funcPointLight(std::vector<Variable*> args){
	static_assert(false, "NOT IMPLEMENTED");
	vec2 position;
	vec3 color;
	pointLight(position,color , SceneVisitor::sceneDescription);
}
void funcPointDirLight(std::vector<Variable*> args){
	static_assert(false, "NOT IMPLEMENTED");
	pointDirLight(, , , SceneVisitor::sceneDescription);
}
void funcPointAngLight(std::vector<Variable*> args){
	static_assert(false, "NOT IMPLEMENTED");
	pointAngLight(, , , SceneVisitor::sceneDescription);
}
void funcCircleLight(std::vector<Variable*> args){
	static_assert(false, "NOT IMPLEMENTED");
	circleLight(, , , SceneVisitor::sceneDescription);
}
void funcCircleAngLight(std::vector<Variable*> args){
	static_assert(false, "NOT IMPLEMENTED");
	circleAngLight(, , , SceneVisitor::sceneDescription);
}
void funcLineLight(std::vector<Variable*> args){
	static_assert(false, "NOT IMPLEMENTED");
	lineLight(, , , SceneVisitor::sceneDescription);
}
void funcLineDirLight(std::vector<Variable*> args){
	static_assert(false, "NOT IMPLEMENTED");
	lineDirLight(, , , SceneVisitor::sceneDescription);
}
void funcMaterial(std::vector<Variable*> args){
	static_assert(false, "NOT IMPLEMENTED");
	vec3 r;
	vec3 t;
	vec3 b;
	vec3 c;
	MaterialType type;
	material(r, t,b ,c,type, SceneVisitor::sceneDescription);
}

struct Function{
	std::vector<Variable::Type> types;
	FuncPtr ptr;
};
struct FunctionTable{
	std::map<std::string,Function> functionTable;
	void init()
	{
		functionTable.insert({ "line",
			Function{
				{
					Variable::Type::VEC2,
					Variable::Type::VEC2,
					Variable::Type::MATERIAL,
					Variable::Type::CONSTANT
				}
			,
				funcLine } });
		functionTable.insert("circle",
			Function{ 
				{
					Variable::Type::VEC2,
					Variable::Type::FLOAT,
				}
				, funcCircle });
		functionTable.insert("pointLight", Function{ 
			{
			}
		, funcPointLight });
		functionTable.insert("pointDirLight", Function{ 
			{
			}
			, funcPointDirLight });
		functionTable.insert("pointAngLight", Function{ 
			{
			}
				, funcPointAngLight });
		functionTable.insert("circleLight", Function{ 
			{
			}
			, funcCircleLight });
		functionTable.insert("circleAngLight", Function{ 
			{
			}
			, funcCircleAngLight });
		functionTable.insert("lineLight", Function{ 
			{
		}, funcLineLight });
		functionTable.insert("lineDirLight", Function{ 
			{
		}, funcLineDirLight });
		functionTable.insert("material", Function{ 
			{
		}, funcMaterial });
	}
};

void materialFunc(std::vector<Variable> * vars, SceneDescription * scene){
	if (vars)
	material(,,,,,scene);
}

void evaluateAST(ASTNode* node){
}



class SceneVisitor :public SceneGrammarVisitor{
	
public:
	static SceneDescription* sceneDescription;
	SceneVisitor(SceneDescription* sd)	{
		sceneDescription = sd;
	}
	SceneDescription* getScene(){
		return sceneDescription;
	}
	virtual antlrcpp::Any visitNumber(SceneGrammarParser::NumberContext *context){
		
	}
	virtual antlrcpp::Any visitScene(SceneGrammarParser::SceneContext *context){
		int i = 0;
		while (SceneGrammarParser::ExpressionContext* exp = context->expression(i)){
			Variable* arg = visit(exp);
			delete arg;
			i++;
		}
		return nullptr;
	}

	virtual antlrcpp::Any visitFunctionExpression(SceneGrammarParser::FunctionExpressionContext *context){
		std::string funcName = context->func->toString();
		std::vector<Variable*>* args = visitFunctionArguments(context->functionArguments());





		for (std::vector<Variable*>::iterator it = args->begin(); it != args->end(); ++it){
			delete (*it);
		}
		delete[]args;

	}
	virtual antlrcpp::Any visitIdentifierExpression(SceneGrammarParser::IdentifierExpressionContext *context){
		Variable *var = new Variable();
		var->type = Variable::Type::ID;
		var->value = new std::string(context->id->toString());
		return var;
	}
	virtual antlrcpp::Any visitConstantExpression(SceneGrammarParser::ConstantExpressionContext *context){
		context->value->toString();
	}

	virtual antlrcpp::Any visitFunctionArguments(SceneGrammarParser::FunctionArgumentsContext *context){
		int i = 0;
		std::vector<Variable*>* args = new std::vector<Variable*>();
		while (SceneGrammarParser::ExpressionContext* exp = context->expression(i))
		{
			Variable* arg=visit(exp);
			args->push_back(arg);
			i++;
		}
		return args;
	}
};
#endif