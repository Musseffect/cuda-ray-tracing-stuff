#pragma once
#ifdef USE_PARSER
#include "CudaScene.cuh"
#include <iostream>
#include "antlr4/antlr4-runtime/antlr4-runtime.h"
#include "SceneGrammarLexer.h"
#include "SceneGrammarParser.h"
#include "SceneVisitor.h"

using namespace antlr4;

void parse(std::string str)
{
	ANTLRInputStream input(str);
	SceneGrammarLexer lexer(&input);
	CommonTokenStream tokens(&lexer);
	SceneGrammarParser parser(&tokens);

	SceneGrammarParser::SceneContext *tree=parser.scene();

	SceneDescription scene;
	SceneVisitor visitor(&scene);
	visitor.visit(tree);
}
#endif