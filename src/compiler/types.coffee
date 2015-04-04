Tokenizer = require("#{__dirname}/../../src/compiler/tokenizer.coffee")
Parser = require("#{__dirname}/../../src/compiler/parser.coffee")
SS = require "./stylesheet"

# helper error class to use for parsing
class NoMatch extends Error
  constructor: (@expected, @found, message) ->
    @name = "No match"
    @message = message ? "#{@expected} expected but #{@found} found"
  toString: () ->
    @name+  ": "+@message
  merge: (f) ->
    if @.found is f.found
      new NoMatch(@.expected + " or " + f.expected, @.found)
    else
      new NoMatch(@.expected + " or " + f.expected, @.found + " and " + f.found, "#{@.message}, #{f.message}")

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
    return @semantic s.consume_next()
  semantic: (token) ->

# helper function to create a type for a token for a specific ident 
class Keyword extends TokenType
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
  semantic: -> true
  constructor: (@token, @semantic = @semantic) ->
    @tokenClass = @token.constructor
    @expected = "'#{@token}'"
    if @token instanceof SS.DelimToken
      @tokenClass = SS.DelimToken
      @props = {value: @token.value}
    else if @token instanceof SS.SimpleToken
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
  constructor: (@a, @semantic = @semantic) ->
  parse: (s) ->
    s.backtrack
      try: =>
        @semantic(@a.parse(s))
      fallback: =>
        @semantic(undefined)
  semantic: Id

# semantic = (a,b) -> [a,b]
class Juxtaposition extends Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    x = @a.parse(s)
    s.optionalWhitespace()
    y = @b.parse(s)
    @semantic(x,y)
    
# semantic = (a,b) -> [a,b]
class CloselyJuxtaposed extends Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    x = @a.parse(s)
    y = @b.parse(s)
    @semantic(x,y)

# semantic = (a) -> a
class ExclusiveOr extends Type
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

class And extends Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    #new Or(new Juxtaposition(@a,@b,@semantic),
    #new Juxtaposition(@b,@a,Swap(@semantic))).parse(s)
    res = s.backtrack
      try: =>
        a: @a.parse(s)
      fallback: (e)=>
        s.backtrack
          try: =>
            b: @b.parse(s)
          fallback: (f)=>
            throw e.merge(f)
    s.optionalWhitespace()
    if "a" of res
      @semantic(res.a, @b.parse(s))
    else
      @semantic(@a.parse(s), res.b)
  semantic: Cons

class InclusiveOr extends Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    new ExclusiveOr(new Juxtaposition(@a,new Optional(@b),@semantic),
            new Juxtaposition(@b,new Optional(@a),Swap(@semantic))).parse(s)
  semantic: Cons


# `m` optional elements of type `a`
max = (m, a, s) ->
  if m <= 0
    # no more needed
    return []
  s.backtrack
    try: =>
      head = a.parse(s)
      s.optionalWhitespace()
      tail = max(m-1, a, s)
      tail.unshift head
      tail
    fallback: (e)=>
      # no more available
      []

class Range extends Type
  semantic: Id
  constructor: (@n,@m,@a,@semantic=@semantic) ->
  parse: (s) ->
    result = []
    i = 0
    while i < @n
      result.push @a.parse(s)
      s.optionalWhitespace()
      ++i
    tail = max(@m-@n, @a, s)
    for i in tail
      result.push i
    @semantic result

class ZeroOrMore extends Range
  constructor: (@a,@semantic = @semantic) ->
    @n = 0
    @m = Infinity

class OneOrMore extends Range
  constructor: (@a,@semantic = @semantic) ->
    @n = 1
    @m = Infinity

class DelimitedBy extends Type
  semantic: Id
  constructor: (@delim, @a, @semantic = @semantic) ->
  parse: (s) ->
    # we create a proxy type for it. The target type, then any number of pairs of
    # the delimiter and the target type. We take the values of the target types
    # and concatenate them in an array.
    new Juxtaposition(
      @a,
      new ZeroOrMore(new Juxtaposition(@delim, @a, Snd)),

      # Finally we add the first target type value then we call the semantic function
      # with the array.
      (x,y)=>y.unshift(x); @semantic(y)
    ).parse(s)

class DelimitedByComma extends DelimitedBy
  constructor: (@a, @semantic = @semantic) ->
    @delim = new Comma


class Eof extends TokenType
  expected: "EOF"
  tokenClass: SS.EOFToken
    
class Full extends Type
  semantic: (x)->x
  constructor: (@a, @semantic = @semantic) ->
  parse: (s) ->
    s.optionalWhitespace()
    result = @a.parse(s)
    s.optionalWhitespace()
    new Eof().parse(s)
    @semantic result

# This class does not affect the parsing, it only keeps track of a mapping
# of the annotations directly (without another Annotation in between) below
# this node.
class AnnotationRoot extends Type
  semantic: Id
  hasAnnotations: false
  constructor: (@a, @semantic = @semantic) ->
    @prepareMappings(@a)
  prepareMappings: (node) ->
    if node instanceof AnnotationRoot
      if node instanceof Annotation
        @hasAnnotations = true
        node.root = @
      node.prepareMappings(node.a)
    else
      if node.a
        @prepareMappings(node.a)
      if node.b
        @prepareMappings(node.b)
    
  # This parses the tree as usual, but also passes a mapping
  # to the semantic function. The mapping maps the names of the direct descendant
  # annotations to their subtree.
  parseWithAnnotations: (s) ->
    @mappings = {}
    # `a.parse(s)` will add mappings to `@mappings`
    result = @a.parse(s)
    @semantic result, @mappings

  parse: (s) ->
    if @hasAnnotations
      @parseWithAnnotations(s)
    else
      @semantic @a.parse(s)

# This node represents the `x:` annotations in the type tree.
# This is a subclass of  AnnotationRoot, as the annotations below this
# will collect their mappings here.
class Annotation extends AnnotationRoot
  root: undefined
  constructor: (@name, @a, @semantic = @semantic) ->
  parse: (s) ->
    if @root
      # Here we add the mapping to the closes AnnotationRoot in the parent chain.
      @root.mappings[@name] = if @hasAnnotations
        @parseWithAnnotations(s)
      else
        @semantic @a.parse(s)
    else
      throw new Error "Annotation used without an AnnotationRoot correctly configured"


# block types - these simply match a block, with the interior matching the given type
class SimpleBlock extends Type
  semantic: (x)->x
  constructor: (@tokenClass, @a, @semantic = @semantic) ->
    @expected = "'#{new @tokenClass}'"
  parse: (s) ->
    next = s.next()
    unless next instanceof SS.SimpleBlock
      throw new NoMatch(@expected, "'#{next}'")
    unless next.token instanceof @tokenClass
      throw new NoMatch(@expected, "'#{next}'")
    s.consume_next()
    return @semantic new Full(@a).parse(new Stream(next.value))


module.exports = {
  Type
  TokenType
  Keyword
  DelimLike
  Ident
  Integer
  Number
  Percentage
  Comma
  String
  NoMatch
  Juxtaposition
  CloselyJuxtaposed
  And
  ExclusiveOr
  InclusiveOr
  Optional
  OneOrMore
  ZeroOrMore
  Range
  DelimitedByComma
  Eof
  Full
  DelimitedBy
  Annotation
  AnnotationRoot
  SimpleBlock
}
