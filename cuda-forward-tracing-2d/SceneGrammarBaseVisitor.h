
// Generated from SceneGrammar.g4 by ANTLR 4.7.2

#pragma once


#include "antlr4-runtime.h"
#include "SceneGrammarVisitor.h"


/**
 * This class provides an empty implementation of SceneGrammarVisitor, which can be
 * extended to create a visitor which only needs to handle a subset of the available methods.
 */
class  SceneGrammarBaseVisitor : public SceneGrammarVisitor {
public:

  virtual antlrcpp::Any visitNumber(SceneGrammarParser::NumberContext *ctx) override {
    return visitChildren(ctx);
  }

  virtual antlrcpp::Any visitScene(SceneGrammarParser::SceneContext *ctx) override {
    return visitChildren(ctx);
  }

  virtual antlrcpp::Any visitFunctionExpression(SceneGrammarParser::FunctionExpressionContext *ctx) override {
    return visitChildren(ctx);
  }

  virtual antlrcpp::Any visitIdentifierExpression(SceneGrammarParser::IdentifierExpressionContext *ctx) override {
    return visitChildren(ctx);
  }

  virtual antlrcpp::Any visitConstantExpression(SceneGrammarParser::ConstantExpressionContext *ctx) override {
    return visitChildren(ctx);
  }

  virtual antlrcpp::Any visitFunctionArguments(SceneGrammarParser::FunctionArgumentsContext *ctx) override {
    return visitChildren(ctx);
  }


};

