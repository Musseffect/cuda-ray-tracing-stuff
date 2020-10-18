
// Generated from SceneGrammar.g4 by ANTLR 4.7.2

#pragma once


#include "antlr4-runtime.h"
#include "SceneGrammarParser.h"



/**
 * This class defines an abstract visitor for a parse tree
 * produced by SceneGrammarParser.
 */
class  SceneGrammarVisitor : public antlr4::tree::AbstractParseTreeVisitor {
public:

  /**
   * Visit parse trees produced by SceneGrammarParser.
   */
    virtual antlrcpp::Any visitNumber(SceneGrammarParser::NumberContext *context) = 0;

    virtual antlrcpp::Any visitScene(SceneGrammarParser::SceneContext *context) = 0;

    virtual antlrcpp::Any visitFunctionExpression(SceneGrammarParser::FunctionExpressionContext *context) = 0;

    virtual antlrcpp::Any visitIdentifierExpression(SceneGrammarParser::IdentifierExpressionContext *context) = 0;

    virtual antlrcpp::Any visitConstantExpression(SceneGrammarParser::ConstantExpressionContext *context) = 0;

    virtual antlrcpp::Any visitFunctionArguments(SceneGrammarParser::FunctionArgumentsContext *context) = 0;


};

