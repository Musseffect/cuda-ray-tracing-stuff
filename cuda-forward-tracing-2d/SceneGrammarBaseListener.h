
// Generated from SceneGrammar.g4 by ANTLR 4.7.2

#pragma once


#include "antlr4-runtime.h"
#include "SceneGrammarListener.h"


/**
 * This class provides an empty implementation of SceneGrammarListener,
 * which can be extended to create a listener which only needs to handle a subset
 * of the available methods.
 */
class  SceneGrammarBaseListener : public SceneGrammarListener {
public:

  virtual void enterNumber(SceneGrammarParser::NumberContext * /*ctx*/) override { }
  virtual void exitNumber(SceneGrammarParser::NumberContext * /*ctx*/) override { }

  virtual void enterScene(SceneGrammarParser::SceneContext * /*ctx*/) override { }
  virtual void exitScene(SceneGrammarParser::SceneContext * /*ctx*/) override { }

  virtual void enterFunctionExpression(SceneGrammarParser::FunctionExpressionContext * /*ctx*/) override { }
  virtual void exitFunctionExpression(SceneGrammarParser::FunctionExpressionContext * /*ctx*/) override { }

  virtual void enterIdentifierExpression(SceneGrammarParser::IdentifierExpressionContext * /*ctx*/) override { }
  virtual void exitIdentifierExpression(SceneGrammarParser::IdentifierExpressionContext * /*ctx*/) override { }

  virtual void enterConstantExpression(SceneGrammarParser::ConstantExpressionContext * /*ctx*/) override { }
  virtual void exitConstantExpression(SceneGrammarParser::ConstantExpressionContext * /*ctx*/) override { }

  virtual void enterFunctionArguments(SceneGrammarParser::FunctionArgumentsContext * /*ctx*/) override { }
  virtual void exitFunctionArguments(SceneGrammarParser::FunctionArgumentsContext * /*ctx*/) override { }


  virtual void enterEveryRule(antlr4::ParserRuleContext * /*ctx*/) override { }
  virtual void exitEveryRule(antlr4::ParserRuleContext * /*ctx*/) override { }
  virtual void visitTerminal(antlr4::tree::TerminalNode * /*node*/) override { }
  virtual void visitErrorNode(antlr4::tree::ErrorNode * /*node*/) override { }

};

