
// Generated from SceneGrammar.g4 by ANTLR 4.7.2


#include "SceneGrammarListener.h"
#include "SceneGrammarVisitor.h"

#include "SceneGrammarParser.h"


using namespace antlrcpp;
using namespace antlr4;

SceneGrammarParser::SceneGrammarParser(TokenStream *input) : Parser(input) {
  _interpreter = new atn::ParserATNSimulator(this, _atn, _decisionToDFA, _sharedContextCache);
}

SceneGrammarParser::~SceneGrammarParser() {
  delete _interpreter;
}

std::string SceneGrammarParser::getGrammarFileName() const {
  return "SceneGrammar.g4";
}

const std::vector<std::string>& SceneGrammarParser::getRuleNames() const {
  return _ruleNames;
}

dfa::Vocabulary& SceneGrammarParser::getVocabulary() const {
  return _vocabulary;
}


//----------------- NumberContext ------------------------------------------------------------------

SceneGrammarParser::NumberContext::NumberContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* SceneGrammarParser::NumberContext::FLOAT() {
  return getToken(SceneGrammarParser::FLOAT, 0);
}

tree::TerminalNode* SceneGrammarParser::NumberContext::INT() {
  return getToken(SceneGrammarParser::INT, 0);
}


size_t SceneGrammarParser::NumberContext::getRuleIndex() const {
  return SceneGrammarParser::RuleNumber;
}

void SceneGrammarParser::NumberContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterNumber(this);
}

void SceneGrammarParser::NumberContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitNumber(this);
}


antlrcpp::Any SceneGrammarParser::NumberContext::accept(tree::ParseTreeVisitor *visitor) {
  if (auto parserVisitor = dynamic_cast<SceneGrammarVisitor*>(visitor))
    return parserVisitor->visitNumber(this);
  else
    return visitor->visitChildren(this);
}

SceneGrammarParser::NumberContext* SceneGrammarParser::number() {
  NumberContext *_localctx = _tracker.createInstance<NumberContext>(_ctx, getState());
  enterRule(_localctx, 0, SceneGrammarParser::RuleNumber);
  size_t _la = 0;

  auto onExit = finally([=] {
    exitRule();
  });
  try {
    enterOuterAlt(_localctx, 1);
    setState(8);
    dynamic_cast<NumberContext *>(_localctx)->value = _input->LT(1);
    _la = _input->LA(1);
    if (!(_la == SceneGrammarParser::FLOAT

    || _la == SceneGrammarParser::INT)) {
      dynamic_cast<NumberContext *>(_localctx)->value = _errHandler->recoverInline(this);
    }
    else {
      _errHandler->reportMatch(this);
      consume();
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- SceneContext ------------------------------------------------------------------

SceneGrammarParser::SceneContext::SceneContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* SceneGrammarParser::SceneContext::EOF() {
  return getToken(SceneGrammarParser::EOF, 0);
}

std::vector<SceneGrammarParser::ExpressionContext *> SceneGrammarParser::SceneContext::expression() {
  return getRuleContexts<SceneGrammarParser::ExpressionContext>();
}

SceneGrammarParser::ExpressionContext* SceneGrammarParser::SceneContext::expression(size_t i) {
  return getRuleContext<SceneGrammarParser::ExpressionContext>(i);
}


size_t SceneGrammarParser::SceneContext::getRuleIndex() const {
  return SceneGrammarParser::RuleScene;
}

void SceneGrammarParser::SceneContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterScene(this);
}

void SceneGrammarParser::SceneContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitScene(this);
}


antlrcpp::Any SceneGrammarParser::SceneContext::accept(tree::ParseTreeVisitor *visitor) {
  if (auto parserVisitor = dynamic_cast<SceneGrammarVisitor*>(visitor))
    return parserVisitor->visitScene(this);
  else
    return visitor->visitChildren(this);
}

SceneGrammarParser::SceneContext* SceneGrammarParser::scene() {
  SceneContext *_localctx = _tracker.createInstance<SceneContext>(_ctx, getState());
  enterRule(_localctx, 2, SceneGrammarParser::RuleScene);
  size_t _la = 0;

  auto onExit = finally([=] {
    exitRule();
  });
  try {
    enterOuterAlt(_localctx, 1);
    setState(13);
    _errHandler->sync(this);
    _la = _input->LA(1);
    while ((((_la & ~ 0x3fULL) == 0) &&
      ((1ULL << _la) & ((1ULL << SceneGrammarParser::FLOAT)
      | (1ULL << SceneGrammarParser::INT)
      | (1ULL << SceneGrammarParser::ID))) != 0)) {
      setState(10);
      expression();
      setState(15);
      _errHandler->sync(this);
      _la = _input->LA(1);
    }
    setState(16);
    match(SceneGrammarParser::EOF);
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- ExpressionContext ------------------------------------------------------------------

SceneGrammarParser::ExpressionContext::ExpressionContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}


size_t SceneGrammarParser::ExpressionContext::getRuleIndex() const {
  return SceneGrammarParser::RuleExpression;
}

void SceneGrammarParser::ExpressionContext::copyFrom(ExpressionContext *ctx) {
  ParserRuleContext::copyFrom(ctx);
}

//----------------- FunctionExpressionContext ------------------------------------------------------------------

tree::TerminalNode* SceneGrammarParser::FunctionExpressionContext::LPAREN() {
  return getToken(SceneGrammarParser::LPAREN, 0);
}

SceneGrammarParser::FunctionArgumentsContext* SceneGrammarParser::FunctionExpressionContext::functionArguments() {
  return getRuleContext<SceneGrammarParser::FunctionArgumentsContext>(0);
}

tree::TerminalNode* SceneGrammarParser::FunctionExpressionContext::RPAREN() {
  return getToken(SceneGrammarParser::RPAREN, 0);
}

tree::TerminalNode* SceneGrammarParser::FunctionExpressionContext::ID() {
  return getToken(SceneGrammarParser::ID, 0);
}

SceneGrammarParser::FunctionExpressionContext::FunctionExpressionContext(ExpressionContext *ctx) { copyFrom(ctx); }

void SceneGrammarParser::FunctionExpressionContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterFunctionExpression(this);
}
void SceneGrammarParser::FunctionExpressionContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitFunctionExpression(this);
}

antlrcpp::Any SceneGrammarParser::FunctionExpressionContext::accept(tree::ParseTreeVisitor *visitor) {
  if (auto parserVisitor = dynamic_cast<SceneGrammarVisitor*>(visitor))
    return parserVisitor->visitFunctionExpression(this);
  else
    return visitor->visitChildren(this);
}
//----------------- ConstantExpressionContext ------------------------------------------------------------------

SceneGrammarParser::NumberContext* SceneGrammarParser::ConstantExpressionContext::number() {
  return getRuleContext<SceneGrammarParser::NumberContext>(0);
}

SceneGrammarParser::ConstantExpressionContext::ConstantExpressionContext(ExpressionContext *ctx) { copyFrom(ctx); }

void SceneGrammarParser::ConstantExpressionContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterConstantExpression(this);
}
void SceneGrammarParser::ConstantExpressionContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitConstantExpression(this);
}

antlrcpp::Any SceneGrammarParser::ConstantExpressionContext::accept(tree::ParseTreeVisitor *visitor) {
  if (auto parserVisitor = dynamic_cast<SceneGrammarVisitor*>(visitor))
    return parserVisitor->visitConstantExpression(this);
  else
    return visitor->visitChildren(this);
}
//----------------- IdentifierExpressionContext ------------------------------------------------------------------

tree::TerminalNode* SceneGrammarParser::IdentifierExpressionContext::ID() {
  return getToken(SceneGrammarParser::ID, 0);
}

SceneGrammarParser::IdentifierExpressionContext::IdentifierExpressionContext(ExpressionContext *ctx) { copyFrom(ctx); }

void SceneGrammarParser::IdentifierExpressionContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterIdentifierExpression(this);
}
void SceneGrammarParser::IdentifierExpressionContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitIdentifierExpression(this);
}

antlrcpp::Any SceneGrammarParser::IdentifierExpressionContext::accept(tree::ParseTreeVisitor *visitor) {
  if (auto parserVisitor = dynamic_cast<SceneGrammarVisitor*>(visitor))
    return parserVisitor->visitIdentifierExpression(this);
  else
    return visitor->visitChildren(this);
}
SceneGrammarParser::ExpressionContext* SceneGrammarParser::expression() {
  ExpressionContext *_localctx = _tracker.createInstance<ExpressionContext>(_ctx, getState());
  enterRule(_localctx, 4, SceneGrammarParser::RuleExpression);

  auto onExit = finally([=] {
    exitRule();
  });
  try {
    setState(25);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 1, _ctx)) {
    case 1: {
      _localctx = dynamic_cast<ExpressionContext *>(_tracker.createInstance<SceneGrammarParser::FunctionExpressionContext>(_localctx));
      enterOuterAlt(_localctx, 1);
      setState(18);
      dynamic_cast<FunctionExpressionContext *>(_localctx)->func = match(SceneGrammarParser::ID);
      setState(19);
      match(SceneGrammarParser::LPAREN);
      setState(20);
      functionArguments();
      setState(21);
      match(SceneGrammarParser::RPAREN);
      break;
    }

    case 2: {
      _localctx = dynamic_cast<ExpressionContext *>(_tracker.createInstance<SceneGrammarParser::IdentifierExpressionContext>(_localctx));
      enterOuterAlt(_localctx, 2);
      setState(23);
      dynamic_cast<IdentifierExpressionContext *>(_localctx)->id = match(SceneGrammarParser::ID);
      break;
    }

    case 3: {
      _localctx = dynamic_cast<ExpressionContext *>(_tracker.createInstance<SceneGrammarParser::ConstantExpressionContext>(_localctx));
      enterOuterAlt(_localctx, 3);
      setState(24);
      dynamic_cast<ConstantExpressionContext *>(_localctx)->value = number();
      break;
    }

    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- FunctionArgumentsContext ------------------------------------------------------------------

SceneGrammarParser::FunctionArgumentsContext::FunctionArgumentsContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

std::vector<SceneGrammarParser::ExpressionContext *> SceneGrammarParser::FunctionArgumentsContext::expression() {
  return getRuleContexts<SceneGrammarParser::ExpressionContext>();
}

SceneGrammarParser::ExpressionContext* SceneGrammarParser::FunctionArgumentsContext::expression(size_t i) {
  return getRuleContext<SceneGrammarParser::ExpressionContext>(i);
}

std::vector<tree::TerminalNode *> SceneGrammarParser::FunctionArgumentsContext::COMMA() {
  return getTokens(SceneGrammarParser::COMMA);
}

tree::TerminalNode* SceneGrammarParser::FunctionArgumentsContext::COMMA(size_t i) {
  return getToken(SceneGrammarParser::COMMA, i);
}


size_t SceneGrammarParser::FunctionArgumentsContext::getRuleIndex() const {
  return SceneGrammarParser::RuleFunctionArguments;
}

void SceneGrammarParser::FunctionArgumentsContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterFunctionArguments(this);
}

void SceneGrammarParser::FunctionArgumentsContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<SceneGrammarListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitFunctionArguments(this);
}


antlrcpp::Any SceneGrammarParser::FunctionArgumentsContext::accept(tree::ParseTreeVisitor *visitor) {
  if (auto parserVisitor = dynamic_cast<SceneGrammarVisitor*>(visitor))
    return parserVisitor->visitFunctionArguments(this);
  else
    return visitor->visitChildren(this);
}

SceneGrammarParser::FunctionArgumentsContext* SceneGrammarParser::functionArguments() {
  FunctionArgumentsContext *_localctx = _tracker.createInstance<FunctionArgumentsContext>(_ctx, getState());
  enterRule(_localctx, 6, SceneGrammarParser::RuleFunctionArguments);
  size_t _la = 0;

  auto onExit = finally([=] {
    exitRule();
  });
  try {
    setState(36);
    _errHandler->sync(this);
    switch (_input->LA(1)) {
      case SceneGrammarParser::FLOAT:
      case SceneGrammarParser::INT:
      case SceneGrammarParser::ID: {
        enterOuterAlt(_localctx, 1);
        setState(27);
        expression();
        setState(32);
        _errHandler->sync(this);
        _la = _input->LA(1);
        while (_la == SceneGrammarParser::COMMA) {
          setState(28);
          match(SceneGrammarParser::COMMA);
          setState(29);
          expression();
          setState(34);
          _errHandler->sync(this);
          _la = _input->LA(1);
        }
        break;
      }

      case SceneGrammarParser::RPAREN: {
        enterOuterAlt(_localctx, 2);

        break;
      }

    default:
      throw NoViableAltException(this);
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

// Static vars and initialization.
std::vector<dfa::DFA> SceneGrammarParser::_decisionToDFA;
atn::PredictionContextCache SceneGrammarParser::_sharedContextCache;

// We own the ATN which in turn owns the ATN states.
atn::ATN SceneGrammarParser::_atn;
std::vector<uint16_t> SceneGrammarParser::_serializedATN;

std::vector<std::string> SceneGrammarParser::_ruleNames = {
  "number", "scene", "expression", "functionArguments"
};

std::vector<std::string> SceneGrammarParser::_literalNames = {
  "", "", "", "", "'('", "')'", "','", "'.'"
};

std::vector<std::string> SceneGrammarParser::_symbolicNames = {
  "", "FLOAT", "INT", "ID", "LPAREN", "RPAREN", "COMMA", "DOT", "NEWLINE", 
  "WHITESPACE"
};

dfa::Vocabulary SceneGrammarParser::_vocabulary(_literalNames, _symbolicNames);

std::vector<std::string> SceneGrammarParser::_tokenNames;

SceneGrammarParser::Initializer::Initializer() {
	for (size_t i = 0; i < _symbolicNames.size(); ++i) {
		std::string name = _vocabulary.getLiteralName(i);
		if (name.empty()) {
			name = _vocabulary.getSymbolicName(i);
		}

		if (name.empty()) {
			_tokenNames.push_back("<INVALID>");
		} else {
      _tokenNames.push_back(name);
    }
	}

  _serializedATN = {
    0x3, 0x608b, 0xa72a, 0x8133, 0xb9ed, 0x417c, 0x3be7, 0x7786, 0x5964, 
    0x3, 0xb, 0x29, 0x4, 0x2, 0x9, 0x2, 0x4, 0x3, 0x9, 0x3, 0x4, 0x4, 0x9, 
    0x4, 0x4, 0x5, 0x9, 0x5, 0x3, 0x2, 0x3, 0x2, 0x3, 0x3, 0x7, 0x3, 0xe, 
    0xa, 0x3, 0xc, 0x3, 0xe, 0x3, 0x11, 0xb, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 
    0x4, 0x3, 0x4, 0x3, 0x4, 0x3, 0x4, 0x3, 0x4, 0x3, 0x4, 0x3, 0x4, 0x5, 
    0x4, 0x1c, 0xa, 0x4, 0x3, 0x5, 0x3, 0x5, 0x3, 0x5, 0x7, 0x5, 0x21, 0xa, 
    0x5, 0xc, 0x5, 0xe, 0x5, 0x24, 0xb, 0x5, 0x3, 0x5, 0x5, 0x5, 0x27, 0xa, 
    0x5, 0x3, 0x5, 0x2, 0x2, 0x6, 0x2, 0x4, 0x6, 0x8, 0x2, 0x3, 0x3, 0x2, 
    0x3, 0x4, 0x2, 0x29, 0x2, 0xa, 0x3, 0x2, 0x2, 0x2, 0x4, 0xf, 0x3, 0x2, 
    0x2, 0x2, 0x6, 0x1b, 0x3, 0x2, 0x2, 0x2, 0x8, 0x26, 0x3, 0x2, 0x2, 0x2, 
    0xa, 0xb, 0x9, 0x2, 0x2, 0x2, 0xb, 0x3, 0x3, 0x2, 0x2, 0x2, 0xc, 0xe, 
    0x5, 0x6, 0x4, 0x2, 0xd, 0xc, 0x3, 0x2, 0x2, 0x2, 0xe, 0x11, 0x3, 0x2, 
    0x2, 0x2, 0xf, 0xd, 0x3, 0x2, 0x2, 0x2, 0xf, 0x10, 0x3, 0x2, 0x2, 0x2, 
    0x10, 0x12, 0x3, 0x2, 0x2, 0x2, 0x11, 0xf, 0x3, 0x2, 0x2, 0x2, 0x12, 
    0x13, 0x7, 0x2, 0x2, 0x3, 0x13, 0x5, 0x3, 0x2, 0x2, 0x2, 0x14, 0x15, 
    0x7, 0x5, 0x2, 0x2, 0x15, 0x16, 0x7, 0x6, 0x2, 0x2, 0x16, 0x17, 0x5, 
    0x8, 0x5, 0x2, 0x17, 0x18, 0x7, 0x7, 0x2, 0x2, 0x18, 0x1c, 0x3, 0x2, 
    0x2, 0x2, 0x19, 0x1c, 0x7, 0x5, 0x2, 0x2, 0x1a, 0x1c, 0x5, 0x2, 0x2, 
    0x2, 0x1b, 0x14, 0x3, 0x2, 0x2, 0x2, 0x1b, 0x19, 0x3, 0x2, 0x2, 0x2, 
    0x1b, 0x1a, 0x3, 0x2, 0x2, 0x2, 0x1c, 0x7, 0x3, 0x2, 0x2, 0x2, 0x1d, 
    0x22, 0x5, 0x6, 0x4, 0x2, 0x1e, 0x1f, 0x7, 0x8, 0x2, 0x2, 0x1f, 0x21, 
    0x5, 0x6, 0x4, 0x2, 0x20, 0x1e, 0x3, 0x2, 0x2, 0x2, 0x21, 0x24, 0x3, 
    0x2, 0x2, 0x2, 0x22, 0x20, 0x3, 0x2, 0x2, 0x2, 0x22, 0x23, 0x3, 0x2, 
    0x2, 0x2, 0x23, 0x27, 0x3, 0x2, 0x2, 0x2, 0x24, 0x22, 0x3, 0x2, 0x2, 
    0x2, 0x25, 0x27, 0x3, 0x2, 0x2, 0x2, 0x26, 0x1d, 0x3, 0x2, 0x2, 0x2, 
    0x26, 0x25, 0x3, 0x2, 0x2, 0x2, 0x27, 0x9, 0x3, 0x2, 0x2, 0x2, 0x6, 
    0xf, 0x1b, 0x22, 0x26, 
  };

  atn::ATNDeserializer deserializer;
  _atn = deserializer.deserialize(_serializedATN);

  size_t count = _atn.getNumberOfDecisions();
  _decisionToDFA.reserve(count);
  for (size_t i = 0; i < count; i++) { 
    _decisionToDFA.emplace_back(_atn.getDecisionState(i), i);
  }
}

SceneGrammarParser::Initializer SceneGrammarParser::_init;
