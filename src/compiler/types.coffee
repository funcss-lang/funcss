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
    @message = "#{expected} expected but #{found} found"
  toString: () ->
    @name+  ": "+@message
  merge: (f) ->
    if @.found is f.found
      new NoMatch(@.expected + " or " + f.expected, @.found)
    else
      new NoMatch(@.expected + " or " + f.expected, @.found + " and " + f.found)



Id = (x) -> x
Swap = (f) -> (x,y) -> debugger; f(y,x)
Or = (x,y) -> x ? y

TokenType = (msg, clazz, props={}) -> (semantic) -> (s) ->
  next = s.next()
  unless next instanceof clazz
    throw new NoMatch(msg, "'#{next}'")
  for k,v of props
    unless next[k] is v
      throw new NoMatch(msg, "'#{next}'")
  return semantic s.consume_next()

IdentType = (value) -> TokenType("'#{value}'", IdentToken, {value})
DelimType = (value) -> TokenType("'#{value}'", DelimToken, {value})
Ident = TokenType("identifier", IdentToken)
Integer = TokenType("integer", NumberToken, type:"integer")
Number = TokenType("number", NumberToken)
String = TokenType("string", StringToken)
Whitespace = TokenType("whitespace", WhitespaceToken)

Stream = require "./stream"
Stream.prototype.backtrack = (options) ->
  try
    p = @position
    return options.try()
  catch e
    if e instanceof NoMatch
      @position = p
      return options.fallback(e)
    else
      throw e

# semantic = (a) -> a ? default
Optional = (a) -> (semantic) -> (s) ->
  s.backtrack
    try: ->
      semantic(a(s))
    fallback: ->
      semantic(undefined)
OptionalWhitespace = Optional(Whitespace(->))(->)

# semantic = (a,b) -> [a,b]
Juxtaposition = (a,b) -> (semantic) -> (s) ->
  x = a(s)
  OptionalWhitespace(s)
  y = b(s)
  semantic(x,y)

# semantic = (a,b) -> [a,b]
DoubleAmpersand = (a,b) -> (semantic) -> (s) ->
  s.backtrack
    try: ->
      x = a(s)
      OptionalWhitespace(s)
      y = b(s)
      semantic(x,y)
    fallback: (e) ->
      s.backtrack
        try: ->
          y = b(s)
          OptionalWhitespace(s)
          x = a(s)
          semantic(x,y)
        fallback: (f)->
          throw e.merge(f)

# semantic = (a,b) -> a ? b
Bar = (a,b) -> (semantic) -> (s) ->
  s.backtrack
    try: ->
      semantic(a(s), undefined)
    fallback: (e)->
      s.backtrack
        try: ->
          semantic(undefined, b(s))
        fallback: (f)->
          throw e.merge(f)

# semantic = (a,b) -> {a:a,b:b}
DoubleBar = (a,b) -> (semantic) -> Bar(
  Juxtaposition(a,Optional(b)(Id))(semantic),
  Juxtaposition(b,Optional(a)(Id))(Swap semantic))(Or)


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
  DoubleBar
}
