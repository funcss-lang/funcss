Tokenizer = require("#{__dirname}/../../src/compiler/tokenizer.coffee")
{
  IdentToken
  FunctionToken
  AtKeywordToken
  HashToken
  StringToken
  BadStringToken
  UrlToken
  BadUrlToken
  DelimToken
  NumberToken
  PercentageToken
  DimensionToken
  UnicodeRangeToken
  IncludeMatchToken
  DashMatchToken
  PrefixMatchToken
  SuffixMatchToken
  SubstringMatchToken
  ColumnToken
  WhitespaceToken
  CDOToken
  CDCToken
  ColonToken
  SemicolonToken
  CommaToken
  OpeningSquareToken
  ClosingSquareToken
  OpeningParenToken
  ClosingParenToken
  OpeningCurlyToken
  ClosingCurlyToken
} = Tokenizer

Parser = require("#{__dirname}/../../src/compiler/parser.coffee")
{
  AtRule
  QualifiedRule
  Declaration
  Function
  SimpleBlock
  SyntaxError
  Stylesheet
} = Parser

class NoMatch extends Error
  constructor: (exptected, found) ->
    @exptected = exptected
    @found = found

TokenType = (msg, clazz, props={}) -> (name) -> (s) ->
  unless s.current instanceof clazz
    throw new NoMatch(msg, s.current)
  for k,v of props
    unless s.current[k] is v
      throw new NoMatch(msg, s.current)
  return s.current

IdentType = (value) -> TokenType("identifier", IdentType, {value})
DelimType = (value) -> TokenType("'#{value}'", DelimToken, {value})
IntegerType = TokenType("integer", NumberToken, type:"integer")
NumberType = TokenType("number", NumberToken)
StringType = TokenType("string", StringToken)

JuxtapositionType = (name) -> (a,b) -> (s) ->
  a(s)
  b(s)

OrType = (a,b) -> (s) ->
  try
    s.push_position()
    return a(i)
  catch e
    if e instanceof NoMatch
      return b(i)
  finally
    s.pop_position()

ColumnType = ->
BothType = ->

GroupType = ->
StarType = ->
PlusType = ->
QuestionmarkType = ->
HashmarkType = ->

AnyValueType = ->

