Tokenizer = require("#{__dirname}/../../src/compiler/tokenizer.coffee")

Parser = require("#{__dirname}/../../src/compiler/parser.coffee")

# helper error class to use for parsing
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

# backtrack algorithm for the stream
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

# helper functions
Id = (x) -> x
Swap = (f) -> (x,y) -> f(y,x)
Or = (x,y) -> x ? y
Cons = (x,y) -> y.unshift x; y
Opt = (y) -> (x) -> x ? y
Snd = (x,y) -> y

# a type which matches a single token of a single class, with optional property restrictions
TokenType = (msg, clazz, props={}) -> (semantic) -> (s) ->
  next = s.next()
  unless next instanceof clazz
    throw new NoMatch(msg, "'#{next}'")
  for k,v of props
    unless next[k] is v
      throw new NoMatch(msg, "'#{next}'")
  return semantic s.consume_next()

# helper function to create a type for a token for a specific ident 
IdentType = (value) -> TokenType("'#{value}'", Tokenizer.IdentToken, {value})

Ident = TokenType("identifier", Tokenizer.IdentToken)
Percentage = TokenType("percentage", Tokenizer.PercentageToken)
Integer = TokenType("integer", Tokenizer.NumberToken, type:"integer")
Number = TokenType("number", Tokenizer.NumberToken)
String = TokenType("string", Tokenizer.StringToken)
Whitespace = TokenType("whitespace", Tokenizer.WhitespaceToken)
Comma = TokenType(",", Tokenizer.CommaToken)(->)

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

DelimitedBy = (delim) -> (a) -> Juxtaposition(a, Star(Juxtaposition(delim,a)(Snd)))(Cons)
Hash = DelimitedBy Comma

module.exports = {
  TokenType
  IdentType
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
  Optional
  Plus
  Star
  Range
  Hash
}
