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
# - `parse(s:String | Array)`: creates a stream from the string or array, then calls `consume()`
# - `consume(s:GR.Stream)`: tries to consume the first few tokens from the stream, calls the semantic 
#     function, and returns the result.
#

assert    = require "../helpers/assert"
Tokenizer = require "./tokenizer"
Parser    = require "./parser"
SS        = require "./ss_nodes"

GR = exports



class GR.Stream
  constructor: (items, @eof) ->
    (@items = (t for t in items)).push new SS.EOFToken(@eof)
    @position = 0
  consume_next: ->
    @current = @items[@position++]
  next: ->
    @items[@position]
  reconsume_current: ->
    @items.unshift(@current)

  # `options` has two fields: `try` and `fallback`. `try` is a function to
  # call. When a `NoMatch` is thrown from `try`, then `fallback` is called.
  backtrack: (options) ->
    try
      p = @position
      return options.try()
    catch e
      if e instanceof GR.NoMatch
        @position = p
        return options.fallback(e)
      else
        throw e

  optionalWhitespace: () ->
    while @next() instanceof SS.WhitespaceToken
      @consume_next()

  noMatchNext: (expected) ->
    throw new GR.NoMatch(expected, @next(), @, @position)

  toStringUntil: (position) ->
    (t for t in @items.slice(0,position)).join("")

  toStringFrom: (position) ->
    (t for t in @items.slice(position)).join("")

# helper error class to use for parsing
class GR.NoMatch extends Error
  constructor: (@expected, @found, @stream, @position) ->
    if @found instanceof SS.SimpleBlock
      @found = @found.token
    else if @found instanceof SS.Function
      @found = new SS.FunctionToken(@found.name)
    @name = "No match"
    @message = message ? "#{@expected} expected but '#{@found}' found"
    @stack = """
    #{@message}
    #{@stackTrace()}"""
  toString: () ->
    @name+  ": "+@message
  merge: (f) ->
    if @.position is f.position
      new GR.NoMatch(@.expected + " or " + f.expected, @.found, @.stream, @.position)
    else
      throw (if @.position < f.position then @ else f)
      #new GR.NoMatch(@.expected + " or " + f.expected, @.found + " and " + f.found, "#{@.message}, #{f.message}")
  stackTrace: ->
    before = @stream.toStringUntil(@position)
    after = @stream.toStringFrom(@position)
    """
    #{before}#{after}
    #{("-" for i in [1..before.length]).join("")+"^"}
    """



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

  # This is the main entry point for parsing for each subclass. It prepares the input if needed
  # and then redirects to `consume`
  parse: (input, eof="") ->
    assert.notInstanceOf {input}, GR.Stream
    input = Parser.parse_list_of_component_values(input) unless input instanceof SS.ComponentValueList
    s = new GR.Stream(input, eof)
    s.optionalWhitespace()
    result = @consume s
    s.optionalWhitespace()
    s.noMatchNext("'#{eof}'") unless (next = s.next()) instanceof SS.EOFToken
    result

  setFs: (@fs) ->
    @a?.setFs(@fs)
    @b?.setFs(@fs)

# a type which matches a single token of a single class, with optional property restrictions
class GR.TokenTypeTokenType extends GR.Type
  props: {}
  consume: (s) ->
    next = s.next()
    if !next?
      throw new Error "Internal Error in FunCSS: nothing returned from stream"
    unless next instanceof @tokenClass
      s.noMatchNext(@expected)
    for k,v of @props
      unless next[k] is v
        s.noMatchNext(@expected)
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
  consume: (s) ->
    s.backtrack
      try: =>
        @semantic(@a.consume(s))
      fallback: =>
        @semantic(undefined)
  semantic: Id

# semantic = (a,b) -> [a,b]
class GR.Juxtaposition extends GR.Type
  constructor: (@a, @b, @semantic = @semantic) ->
  consume: (s) ->
    x = @a.consume(s)
    s.optionalWhitespace()
    y = @b.consume(s)
    @semantic(x,y)
    
# semantic = (a,b) -> [a,b]
class GR.CloselyJuxtaposed extends GR.Type
  constructor: (@a, @b, @semantic = @semantic) ->
    assert.function {@semantic}
  consume: (s) ->
    x = @a.consume(s)
    y = @b.consume(s)
    @semantic(x,y)

# semantic = (a) -> a
class GR.ExclusiveOr extends GR.Type
  constructor: (@a, @b, @semantic = @semantic) ->
  consume: (s) ->
    s.backtrack
      try: =>
        @semantic(@a.consume(s))
      fallback: (e)=>
        s.backtrack
          try: =>
            @semantic(@b.consume(s))
          fallback: (f)=>
            throw e.merge(f)
  semantic: Id

class GR.And extends GR.Type
  constructor: (@a, @b, @semantic = @semantic) ->
  consume: (s) ->
    #new Or(new GR.Juxtaposition(@a,@b,@semantic),
    #new GR.Juxtaposition(@b,@a,Swap(@semantic))).consume(s)
    res = s.backtrack
      try: =>
        a: @a.consume(s)
      fallback: (e)=>
        s.backtrack
          try: =>
            b: @b.consume(s)
          fallback: (f)=>
            throw e.merge(f)
    s.optionalWhitespace()
    if "a" of res
      @semantic(res.a, @b.consume(s))
    else
      @semantic(@a.consume(s), res.b)
  semantic: Cons

class GR.InclusiveOr extends GR.Type
  constructor: (@a, @b, @semantic = @semantic) ->
  consume: (s) ->
    new GR.ExclusiveOr(new GR.Juxtaposition(@a,new GR.Optional(@b),@semantic),
            new GR.Juxtaposition(@b,new GR.Optional(@a),Swap(@semantic))).consume(s)
  semantic: Cons


# `m` optional elements of type `a`
max = (m, a, s) ->
  if m <= 0
    # no more needed
    return []
  s.backtrack
    try: =>
      head = a.consume(s)
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
  consume: (s) ->
    result = []
    i = 0
    while i < @n
      result.push @a.consume(s)
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
  consume: (s) ->
    # we create a proxy type for it. The target type, then any number of pairs of
    # the delimiter and the target type. We take the values of the target types
    # and concatenate them in an array.
    new GR.Juxtaposition(
      @a,
      new GR.ZeroOrMore(new GR.Juxtaposition(@delim, @a, Snd)),

      # Finally we add the first target type value then we call the semantic function
      # with the array.
      (x,y)=>y.unshift(x); @semantic(y)
    ).consume(s)

class GR.DelimitedByComma extends GR.DelimitedBy
  constructor: (@a, @semantic = @semantic) ->
    @delim = new GR.Comma



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
    # `a.consume(s)` will add mappings to `@mappings`
    result = @a.consume(s)
    @semantic result, @mappings

  consume: (s) ->
    if @hasAnnotations
      @parseWithAnnotations(s)
    else
      @semantic @a.consume(s)

# This node represents the `x:` annotations in the type tree.
# This is a subclass of  GR.AnnotationRoot, as the annotations below this
# will collect their mappings here.
class GR.Annotation extends GR.AnnotationRoot
  root: undefined
  constructor: (@name, @a, @semantic = @semantic) ->
  consume: (s) ->
    if @root
      # Here we add the mapping to the closes GR.AnnotationRoot in the parent chain.
      @root.mappings[@name] = if @hasAnnotations
        @parseWithAnnotations(s)
      else
        @semantic @a.consume(s)
    else
      throw new Error "GR.Annotation used without an GR.AnnotationRoot correctly configured"


# block types - these simply match a block, with the interior matching the given type
class GR.SimpleBlock extends GR.Type
  semantic: (x)->x
  constructor: (@tokenClass, @a, @semantic = @semantic) ->
    @expected = "'#{new @tokenClass}'"
  consume: (s) ->
    next = s.next()
    unless next instanceof SS.SimpleBlock
      s.noMatchNext(@expected)
    unless next.token instanceof @tokenClass
      s.noMatchNext(@expected)
    s.consume_next()
    return @semantic @a.parse(next.value, "#{new((new @tokenClass).mirror())}")

# A special type that refers to another type.
class GR.TypeReference extends GR.Type
  semantic: Id
  constructor: (@name, @quoted = no, @semantic = @semantic) ->
    @expected = @name
  consume: (s) ->
    if ! @fs
      throw new Error "Internal error in FunCSS: fs is not set up correctly"
    type = if @quoted then @fs.getPropertyType(@name) else @fs.getType(@name)
    type.consume(s)


class GR.FunctionalNotation extends GR.Type
  semantic: Id
  constructor: (@name, @a, @semantic=@semantic) ->
    @expected = "'#{@name}('"
  consume: (s) ->
    next = s.next()
    unless next instanceof SS.Function
      s.noMatchNext(@expected)
    unless next.name is @name
      s.noMatchNext(@expected)
    s.consume_next()
    return @semantic @a.parse(next.value, ")")

class GR.AnyFunctionalNotation extends GR.Type
  expected: "function"
  semantic: (name, x) -> throw Error "No semantic function for GR.AnyFunctionalNotation"
  constructor: (@a, @semantic = @semantic) ->
  consume: (s) ->
    next = s.next()
    unless next instanceof SS.Function
      s.noMatchNext(@expected)
    s.consume_next()
    return @semantic next.name, @a.parse(next.value, ")")

class GR.RawTokens extends GR.Type
  semantic: Id
  constructor: (@semantic = @semantic)->
  consume: (s) ->
    result = new SS.ComponentValueList
    next = s.next()
    until next instanceof SS.EOFToken
      result.push next
      s.consume_next()
      next = s.next()
    @semantic result

# This does not touch the input stream, just calls the semantic function
class GR.Empty extends GR.Type
  semantic: ->
  consume: (s) -> @semantic()

# This is a pass-through grammar, it can be used to add an additional semantic function.
class GR.Just extends GR.Type
  semantic: Id
  constructor: (@a, @semantic = @semantic) ->
  consume: (s) -> @semantic @a.consume(s)

