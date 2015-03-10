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



Id = (x) -> x
Swap = (f) -> (x,y) -> f(y,x)
Or = (x,y) -> x ? y
Cons = (x,y) -> y.unshift x; y
Opt = (y) -> (x) -> x ? y
Snd = (x,y) -> y

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
Percentage = TokenType("percentage", PercentageToken)
Integer = TokenType("integer", NumberToken, type:"integer")
Number = TokenType("number", NumberToken)
String = TokenType("string", StringToken)
Whitespace = TokenType("whitespace", WhitespaceToken)
Comma = TokenType(",", CommaToken)(->)

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

# semantic = (a,b) -> a ? b
Bar = (a,b) -> (semantic) -> (s) ->
  s.backtrack
    try: ->
      semantic(a(s))
    fallback: (e)->
      s.backtrack
        try: ->
          semantic(b(s))
        fallback: (f)->
          throw e.merge(f)

# semantic = (a,b) -> [a,b]
DoubleAmpersand = (a,b) -> (semantic) -> Bar(
  Juxtaposition(a,b)(semantic),
  Juxtaposition(b,a)(Swap semantic)
)(Id)


# semantic = (a,b) -> {a:a,b:b}
DoubleBar = (a,b) -> (semantic) -> Bar(
  Juxtaposition(a,Optional(b)(Id))(semantic),
  Juxtaposition(b,Optional(a)(Id))(Swap semantic)
)(Id)

# m optional elements of type a
Max = (m) -> (a) -> (s) ->
  if m <= 0
    # no more needed
    return []
  s.backtrack
    try: ->
      head = a(s)
      OptionalWhitespace(s)
      tail = Max(m-1)(a)(s)
      tail.unshift head
      tail
    fallback: (e)->
      # no more available
      []

Range = (n,m) -> (a) -> (s) ->
  result = []
  i = 0
  while i < n
    result.push a(s)
    OptionalWhitespace(s)
    ++i
  tail = Max(m-n)(a)(s)
  for i in tail
    result.push i
  result

Star = Max(Infinity)
Plus = Range(1,Infinity)

Hash = (a) -> Juxtaposition(a,Star(Juxtaposition(Comma,a)(Snd)))(Cons)

AnyValue = ->

module.exports = {
  IdentType
  DelimType
  Ident
  Integer
  Number
  Percentage
  Comma
  String
  NoMatch
  Juxtaposition
  DoubleAmpersand
  Bar
  DoubleBar
  Plus
  Star
  Range
  Hash
  AnyValue
}
