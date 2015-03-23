Tokenizer = require("#{__dirname}/../../src/compiler/tokenizer.coffee")
Parser = require("#{__dirname}/../../src/compiler/parser.coffee")
SS = require "./stylesheet"

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

Stream.prototype.optionalWhitespace = () ->
  while @next() instanceof SS.WhitespaceToken
    @consume_next()

# helper functions
Id = (x) -> x
Swap = (f) -> (x,y) -> f(y,x)
Or = (x,y) -> x ? y
Cons = (x,y) -> y.unshift x; y
Opt = (y) -> (x) -> x ? y
Snd = (x,y) -> y


# base class for all types
class Type
  constructor: (@semantic = @semantic) ->

# a type which matches a single token of a single class, with optional property restrictions
class TokenType extends Type
  props: {}
  parse: (s) ->
    next = s.next()
    unless next instanceof @tokenClass
      throw new NoMatch(@expected, "'#{next}'")
    for k,v of @props
      unless next[k] is v
        throw new NoMatch(@expected, "'#{next}'")
    debugger
    return @semantic s.consume_next()
  semantic: (token) ->

# helper function to create a type for a token for a specific ident 
class IdentType extends TokenType
  tokenClass: SS.IdentToken
  constructor: (@value, @semantic = @semantic) ->
    @expected = "'#{@value}'"
    @props = {@value}
  semantic: (token) ->
    token.value
    
class Ident extends TokenType
  expected: "identifier"
  tokenClass: SS.IdentToken
  semantic: (token) ->
    token.value


class Percentage extends TokenType
  expected: "percentage"
  tokenClass: SS.PercentageToken
  semantic: (token) ->
    token.value / 100

class Number extends TokenType
  expected: "number"
  tokenClass: SS.NumberToken
  semantic: (token) ->
    token.value

class Integer extends Number
  expected: "integer"
  props: {type: "integer"}

class String extends TokenType
  expected: "string"
  tokenClass: SS.StringToken
  semantic: (token) ->
    token.value

class Whitespace extends TokenType
  expected: "whitespace"
  tokenClass: SS.WhitespaceToken

class DelimLike extends TokenType
  constructor: (@token, @semantic = @semantic) ->
    @tokenClass = @token.constructor
    @expected = "'#{@token}'"
    if token instanceof SS.DelimToken
      @tokenClass = SS.DelimToken
      @props = {value: token.value}
    else if token instanceof SS.SimpleToken
      return
    else
      throw new Error "DelimLike expects a DelimToken or a SimpleToken, #{@token.constructor.name} got instead"




class Comma extends TokenType
  expected: "','"
  tokenClass: SS.CommaToken

#### Parser combinators
#
# semantic = (a) -> a ? default
class Optional extends Type
  constructor: (@value, @semantic = @semantic) ->
  parse: (s) ->
    s.backtrack
      try: =>
        @semantic(@value.parse(s))
      fallback: =>
        @semantic(undefined)
  semantic: Id

# semantic = (a,b) -> [a,b]
class Juxtaposition
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    x = @a.parse(s)
    s.optionalWhitespace()
    y = @b.parse(s)
    @semantic(x,y)
  semantic: Cons
    

# semantic = (a) -> a
class Bar extends Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    s.backtrack
      try: =>
        @semantic(@a.parse(s))
      fallback: (e)=>
        s.backtrack
          try: =>
            @semantic(@b.parse(s))
          fallback: (f)=>
            throw e.merge(f)
  semantic: Id

class DoubleAmpersand extends Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    new Bar(new Juxtaposition(@a,@b,@semantic),
            new Juxtaposition(@b,@a,Swap(@semantic))).parse(s)
  semantic: Cons

class DoubleBar extends Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    new Bar(new Juxtaposition(@a,new Optional(@b),@semantic),
            new Juxtaposition(@b,new Optional(@a),Swap(@semantic))).parse(s)
  semantic: Cons


# `m` optional elements of type `a`
class Max extends Type
  constructor: (@m, @a) ->
  parse: (s) ->
    if @m <= 0
      # no more needed
      return []
    s.backtrack
      try: =>
        head = @a.parse(s)
        s.optionalWhitespace()
        tail = new Max(@m-1, @a).parse(s)
        tail.unshift head
        tail
      fallback: (e)=>
        # no more available
        []
    
class Range extends Type
  constructor: (@n,@m,@a) ->
  parse: (s) ->
    result = []
    i = 0
    while i < @n
      result.push @a.parse(s)
      s.optionalWhitespace()
      ++i
    tail = new Max(@m-@n, @a).parse(s)
    for i in tail
      result.push i
    result

class Star extends Max
  constructor: (@a) ->
    @m = Infinity

class Plus extends Range
  constructor: (@a) ->
    @n = 1
    @m = Infinity

class DelimitedBy extends Type
  constructor: (@delim, @a) ->
  parse: (s) ->
    new Juxtaposition(@a, new Star(new Juxtaposition(@delim, @a, Snd)), Cons).parse(s)

class Hash extends DelimitedBy
  constructor: (@a) ->
    @delim = new Comma





module.exports = {
  TokenType
  IdentType
  DelimLike
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
