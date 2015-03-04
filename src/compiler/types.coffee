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
  constructor: (expected, found) ->
    @expected = expected
    @found = found
    @name = "No match"
    @message = "expected #{expected} but #{found} found"
  toString: () ->
    @name+  ": "+@message



TokenType = (msg, clazz, props={}) -> (semantic) -> (s) ->
  next = s.next()
  unless next instanceof clazz
    throw new NoMatch(msg, "'#{next}'")
  for k,v of props
    unless next[k] is v
      throw new NoMatch(msg, next)
  return semantic s.consume_next()

IdentType = (value) -> TokenType("'#{value}'", IdentToken, {value})
DelimType = (value) -> TokenType("'#{value}'", DelimToken, {value})
Ident = TokenType("identifier", IdentToken)
Integer = TokenType("integer", NumberToken, type:"integer")
Number = TokenType("number", NumberToken)
String = TokenType("string", StringToken)
WhitespaceType = TokenType("whitespace", WhitespaceToken)

backtrack = (s, f) ->
  try
    p = s.position
    return f()
  catch e
    if e instanceof NoMatch
      s.position = p
    throw e

Optional = (a) -> (semantic) -> (s) ->
  semantic backtrack s, -> a(s)
OptionalWhitespace = Optional(WhitespaceType(->))(->)

# semantic = (a,b) -> [a,b]
Juxtaposition = (a,b) -> (semantic) -> (s) ->
  x = a(s)
  OptionalWhitespace(s)
  y = b(s)
  return semantic x,y

# semantic = (a,b) -> [a,b]
DoubleAmpersand = (a,b) -> (semantic) -> (s) ->
  try
    backtrack s, ->
      x = a(s)
      OptionalWhitespace(s)
      y = b(s)
      return semantic(x,y)
  catch e
    if e instanceof NoMatch
      try
        y = b(s)
        OptionalWhitespace(s)
        x = a(s)
        return semantic(x,y)
      catch f
        if e.found is f.found
          throw new NoMatch(e.expected + " or " + f.expected, e.found)
        else
          throw new NoMatch(e.expected + " or " + f.expected, e.found + " and " + f.found)

# semantic = (a,b) -> a ? b
Bar = (a,b) -> (semantic) -> (s) ->
  debugger
  try
    semantic(backtrack(s,-> a(s)), undefined)
  catch e
    if e instanceof NoMatch
      try
        semantic(undefined, backtrack(s,-> b(s)))
      catch f
        if f instanceof NoMatch
          if e.found is f.found
            throw new NoMatch(e.expected + " or " + f.expected, e.found)
          else
            throw new NoMatch(e.expected + " or " + f.expected, e.found + " and " + f.found)
        throw f

# semantic = (a,b) -> {a:a,b:b}
DoubleBar = (a,b) -> (semantic) -> (s) ->

GroupType = ->
StarType = ->
PlusType = ->
QuestionmarkType = ->
HashmarkType = ->

AnyValueType = ->

module.exports = {
  IdentType
  DelimType
  Ident
  Integer
  Number
  String
  NoMatch
  Juxtaposition
  DoubleAmpersand
  Bar
}
