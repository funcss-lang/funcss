## The Grammar Nodes
#
# These nodes represent the grammar of different sublanguages
# (e.g. selectors, vds, and each property value type).
#
# The last optional parameter of all `GR` constructors is the semantic function: a function
# which returns the final value from the elements of the parsed string. The schema of the
# semantic function varies between `GR` classes.
#
# *Output*
# 
# - `parse(s:Stream)`: tries to consume the first few tokens from the stream, calls the semantic 
#     function, and returns the result.
#

assert    = require "../helpers/assert"
Stream    = require "../helpers/stream"
Tokenizer = require "./tokenizer"
Parser    = require "./parser"
SS        = require "./ss_nodes"

GR = exports
# helper error class to use for parsing
class GR.NoMatch extends Error
  constructor: (@expected, @found, message) ->
    @name = "No match"
    @message = message ? "#{@expected} expected but #{@found} found"
  toString: () ->
    @name+  ": "+@message
  merge: (f) ->
    if @.found is f.found
      new GR.NoMatch(@.expected + " or " + f.expected, @.found)
    else
      new GR.NoMatch(@.expected + " or " + f.expected, @.found + " and " + f.found, "#{@.message}, #{f.message}")

# backtrack algorithm for the stream
Stream.prototype.backtrack = (options) ->
  try
    p = @position
    return options.try()
  catch e
    if e instanceof GR.NoMatch
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
class GR.Type
  constructor: (@semantic = @semantic) ->
  setFs: (@fs) ->
    @a?.setFs(@fs)
    @b?.setFs(@fs)

# a type which matches a single token of a single class, with optional property restrictions
class GR.TokenTypeTokenType extends GR.Type
  props: {}
  parse: (s) ->
    next = s.next()
    if !next?
      throw new Error "Internal Error in FunCSS: nothing returned from stream"
    unless next instanceof @tokenClass
      throw new GR.NoMatch(@expected, "'#{next}'")
    for k,v of @props
      unless next[k] is v
        throw new GR.NoMatch(@expected, "'#{next}'")
    return @semantic s.consume_next()
  semantic: (token) ->

# helper function to create a type for a token for a specific ident 
class GR.Keyword extends GR.TokenTypeTokenType
  tokenClass: SS.IdentToken
  constructor: (@value, @semantic = @semantic) ->
    @expected = "'#{@value}'"
    @props = {@value}
  semantic: (token) ->
    token.value
    
class GR.Ident extends GR.TokenTypeTokenType
  expected: "identifier"
  tokenClass: SS.IdentToken
  semantic: (token) ->
    token.value


class GR.Percentage extends GR.TokenTypeTokenType
  expected: "percentage"
  tokenClass: SS.PercentageToken
  semantic: (token) ->
    token.value / 100

class GR.Number extends GR.TokenTypeTokenType
  expected: "number"
  tokenClass: SS.NumberToken
  semantic: (token) ->
    token.value

class GR.Integer extends GR.Number
  expected: "integer"
  props: {type: "integer"}

class GR.String extends GR.TokenTypeTokenType
  expected: "string"
  tokenClass: SS.StringToken
  semantic: (token) ->
    token.value

class Whitespace extends GR.TokenTypeTokenType
  expected: "whitespace"
  tokenClass: SS.WhitespaceToken

class GR.DelimLike extends GR.TokenTypeTokenType
  semantic: -> "#{@token}"
  constructor: (@token, @semantic = @semantic) ->
    @tokenClass = @token.constructor
    @expected = "'#{@token}'"
    if @token instanceof SS.DelimToken
      @tokenClass = SS.DelimToken
      @props = {value: @token.value}
    else if @token instanceof SS.SimpleToken
      return
    else
      throw new Error "GR.DelimLike expects a DelimToken or a SimpleToken, #{@token.constructor.name} got instead"




class GR.Comma extends GR.TokenTypeTokenType
  expected: "','"
  tokenClass: SS.CommaToken

#### Parser combinators
#
# semantic = (a) -> a ? default
class GR.Optional extends GR.Type
  constructor: (@a, @semantic = @semantic) ->
  parse: (s) ->
    s.backtrack
      try: =>
        @semantic(@a.parse(s))
      fallback: =>
        @semantic(undefined)
  semantic: Id

# semantic = (a,b) -> [a,b]
class GR.Juxtaposition extends GR.Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    x = @a.parse(s)
    s.optionalWhitespace()
    y = @b.parse(s)
    @semantic(x,y)
    
# semantic = (a,b) -> [a,b]
class GR.CloselyJuxtaposed extends GR.Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    x = @a.parse(s)
    y = @b.parse(s)
    @semantic(x,y)

# semantic = (a) -> a
class GR.ExclusiveOr extends GR.Type
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

class GR.And extends GR.Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    #new Or(new GR.Juxtaposition(@a,@b,@semantic),
    #new GR.Juxtaposition(@b,@a,Swap(@semantic))).parse(s)
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

class GR.InclusiveOr extends GR.Type
  constructor: (@a, @b, @semantic = @semantic) ->
  parse: (s) ->
    new GR.ExclusiveOr(new GR.Juxtaposition(@a,new GR.Optional(@b),@semantic),
            new GR.Juxtaposition(@b,new GR.Optional(@a),Swap(@semantic))).parse(s)
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

class GR.Range extends GR.Type
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

class GR.ZeroOrMore extends GR.Range
  constructor: (@a,@semantic = @semantic) ->
    @n = 0
    @m = Infinity

class GR.OneOrMore extends GR.Range
  constructor: (@a,@semantic = @semantic) ->
    @n = 1
    @m = Infinity

class GR.DelimitedBy extends GR.Type
  semantic: Id
  constructor: (@delim, @a, @semantic = @semantic) ->
  parse: (s) ->
    # we create a proxy type for it. The target type, then any number of pairs of
    # the delimiter and the target type. We take the values of the target types
    # and concatenate them in an array.
    new GR.Juxtaposition(
      @a,
      new GR.ZeroOrMore(new GR.Juxtaposition(@delim, @a, Snd)),

      # Finally we add the first target type value then we call the semantic function
      # with the array.
      (x,y)=>y.unshift(x); @semantic(y)
    ).parse(s)

class GR.DelimitedByComma extends GR.DelimitedBy
  constructor: (@a, @semantic = @semantic) ->
    @delim = new GR.Comma


class GR.Eof extends GR.TokenTypeTokenType
  expected: "EOF"
  tokenClass: SS.EOFToken
    
class GR.Full extends GR.Type
  semantic: (x)->x
  constructor: (@a, @semantic = @semantic) ->
    assert.hasProp {@a}, "parse"
    assert.notInstanceOf {@a}, GR.Full
  parse: (s) ->
    s.optionalWhitespace()
    result = @a.parse(s)
    s.optionalWhitespace()
    new GR.Eof().parse(s)
    @semantic result

# This class does not affect the parsing, it only keeps track of a mapping
# of the annotations directly (without another GR.Annotation in between) below
# this node.
class GR.AnnotationRoot extends GR.Type
  semantic: Id
  hasAnnotations: false
  constructor: (@a, @semantic = @semantic) ->
    @prepareMappings(@a)
  prepareMappings: (node) ->
    if node instanceof GR.AnnotationRoot
      if node instanceof GR.Annotation
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
# This is a subclass of  GR.AnnotationRoot, as the annotations below this
# will collect their mappings here.
class GR.Annotation extends GR.AnnotationRoot
  root: undefined
  constructor: (@name, @a, @semantic = @semantic) ->
  parse: (s) ->
    if @root
      # Here we add the mapping to the closes GR.AnnotationRoot in the parent chain.
      @root.mappings[@name] = if @hasAnnotations
        @parseWithAnnotations(s)
      else
        @semantic @a.parse(s)
    else
      throw new Error "GR.Annotation used without an GR.AnnotationRoot correctly configured"


# block types - these simply match a block, with the interior matching the given type
class GR.SimpleBlock extends GR.Type
  semantic: (x)->x
  constructor: (@tokenClass, @a, @semantic = @semantic) ->
    @expected = "'#{new @tokenClass}'"
  parse: (s) ->
    next = s.next()
    unless next instanceof SS.SimpleBlock
      throw new GR.NoMatch(@expected, "'#{next}'")
    unless next.token instanceof @tokenClass
      throw new GR.NoMatch(@expected, "'#{next}'")
    s.consume_next()
    return @semantic new GR.Full(@a).parse(new Stream(next.value))

# A special type that refers to another type.
class GR.TypeReference extends GR.Type
  semantic: Id
  constructor: (@name, @quoted = no, @semantic = @semantic) ->
    @expected = @name
  parse: (s) ->
    if ! @fs
      throw new Error "Internal error in FunCSS: fs is not set up correctly"
    type = if @quoted then @fs.getPropertyType(@name) else @fs.getType(@name)
    type.parse(s)


class GR.FunctionalNotation extends GR.Type
  semantic: Id
  constructor: (@name, @a, @semantic=@semantic) ->
    @expected = "'#{@name}('"
  parse: (s) ->
    next = s.next()
    unless next instanceof SS.Function
      throw new GR.NoMatch(@expected, "'#{next}'")
    unless next.name is @name
      throw new GR.NoMatch(@expected, "'#{next}'")
    s.consume_next()
    return @semantic new GR.Full(@a).parse(new Stream(next.value))

class GR.AnyFunctionalNotation extends GR.Type
  expected: "function"
  semantic: (name, x) -> throw Error "No semantic function for GR.AnyFunctionalNotation"
  constructor: (@a, @semantic = @semantic) ->
  parse: (s) ->
    next = s.next()
    unless next instanceof SS.Function
      throw new GR.NoMatch(@expected, "'#{next}'")
    s.consume_next()
    return @semantic next.name, new GR.Full(@a).parse(new Stream(next.value))

class GR.RawTokens extends GR.Type
  semantic: Id
  constructor: (@semantic = @semantic)->
  parse: (s) ->
    result = new SS.ComponentValueList
    next = s.consume_next()
    until next instanceof SS.EOFToken
      result.push next
      next = s.consume_next()
    @semantic result

# This does not touch the input stream, just calls the semantic function
class GR.Empty extends GR.Type
  semantic: ->
  parse: (s) -> @semantic()

# This is a pass-through grammar, it can be used to add an additional semantic function.
class GR.Just extends GR.Type
  semantic: Id
  constructor: (@a, @semantic = @semantic) ->
  parse: (s) -> @semantic @a.parse(s)

