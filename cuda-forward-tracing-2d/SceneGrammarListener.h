
// Generated from SceneGrammar.g4 by ANTLR 4.7.2

#pragma once


#include "antlr4-runtime.h"
#include "SceneGrammarParser.h"


/**
 * This interface defines an abstract listener for a parse tree produced by SceneGrammarParser.
 */
class  SceneGrammarListener : public antlr4::tree::ParseTreeListener {
public:

  virtual void enterNumber(SceneGrammarParser::NumberContext *ctx) = 0;
  virtual void exitNumber(SceneGrammarParser::NumberContext *ctx) = 0;

  virtual void enterScene(SceneGrammarParser::SceneContext *ctx) = 0;
  virtual void exitScene(SceneGrammarParser::SceneContext *ctx) = 0;

  virtual void enterFunctionExpression(SceneGrammarParser::FunctionExpressionContext *ctx) = 0;
  virtual void exitFunctionExpression(SceneGrammarParser::FunctionExpressionContext *ctx) = 0;

  virtual void enterIdentifierExpression(SceneGrammarParser::IdentifierExpressionContext *ctx) = 0;
  virtual void exitIdentifierExpression(SceneGrammarParser::IdentifierExpressionContext *ctx) = 0;

  virtual void enterConstantExpression(SceneGrammarParser::ConstantExpressionContext *ctx) = 0;
  virtual void exitConstantExpression(SceneGrammarParser::ConstantExpressionContext *ctx) = 0;

  virtual void enterFunctionArguments(SceneGrammarParser::FunctionArgumentsContext *ctx) = 0;
  virtual void exitFunctionArguments(SceneGrammarParser::FunctionArgumentsContext *ctx) = 0;


};

