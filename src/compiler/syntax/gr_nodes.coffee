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
    return

  noMatchNext: (expected) ->
    throw new GR.NoMatch(expected, @next(), @, @position)
  noMatchCurrent: (expected) ->
    throw new GR.NoMatch(expected, @current, @, @position-1)

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
      # FIXME they might not be in the same stream...
      throw (if @.position > f.position then @ else f)
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
class GR.Grammar
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
    s.noMatchNext("'#{eof}'") unless s.next() instanceof SS.EOFToken
    result

  setFs: (@fs) ->
    @a?.setFs(@fs)
    @b?.setFs(@fs)
    @


# a type which matches a single token of a single class, with optional property restrictions
class GR.TokenTypeGrammar extends GR.Grammar
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
class GR.Keyword extends GR.TokenTypeGrammar
  tokenClass: SS.IdentToken
  constructor: (@value, @semantic = @semantic) ->
    @expected = "'#{@value}'"
    @props = {@value}
  semantic: (token) ->
    token.value
  toString: -> @value
    
class GR.Ident extends GR.TokenTypeGrammar
  expected: "identifier"
  tokenClass: SS.IdentToken
  semantic: (token) ->
    token.value


class GR.Percentage extends GR.TokenTypeGrammar
  expected: "percentage"
  tokenClass: SS.PercentageToken
  semantic: (token) ->
    token.value / 100

class GR.Number extends GR.TokenTypeGrammar
  expected: "number"
  tokenClass: SS.NumberToken
  semantic: (token) ->
    token.value

class GR.Integer extends GR.Number
  expected: "integer"
  props: {type: "integer"}

class GR.String extends GR.TokenTypeGrammar
  expected: "string"
  tokenClass: SS.StringToken
  semantic: (token) ->
    token.value

class GR.Url extends GR.TokenTypeGrammar
  expected: "url"
  tokenClass: SS.UrlToken
  semantic: (token) ->
    token.value

class GR.Hash extends GR.TokenTypeGrammar
  expected: "#"
  tokenClass: SS.HashToken
  semantic: (token) ->
    token.value

class GR.Dimension extends GR.TokenTypeGrammar
  constructor: (@metricName, @semantic = @semantic) ->
    @expected = @metricName
  tokenClass: SS.DimensionToken
  consume: (s) ->
    # We need to save a reference to the stream so that the semantic function can issue a noMatch
    @stream = s
    # otherwise everything the same
    super(s)

class GR.DelimLike extends GR.TokenTypeGrammar
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
  toString: -> @token.toString()




class GR.Comma extends GR.TokenTypeGrammar
  expected: "','"
  tokenClass: SS.CommaToken
  toString: -> ","

#### Parser combinators
#
# semantic = (a) -> a ? default
class GR.Optional extends GR.Grammar
  constructor: (@a, @semantic = @semantic) ->

  # This is reimplemented so that a more meaningful error message can be thrown.
  #
  # This happens for new `Optional("hello world").parse("hello wld")`. The superclass
  # behavior would throw a NoMatch for the first item - "" expected but "hello" found, which
  # is true but not at all helpful.
  #
  parse: (input, eof="") ->
    # TODO these lines could be deduplicated
    assert.notInstanceOf {input}, GR.Stream
    input = Parser.parse_list_of_component_values(input) unless input instanceof SS.ComponentValueList
    s = new GR.Stream(input, eof)
    s.optionalWhitespace()
    return @semantic(undefined) if s.next() instanceof SS.EOFToken
    result = @semantic(@a.consume(s))
    s.optionalWhitespace()
    s.noMatchNext("'#{eof}'") unless s.next() instanceof SS.EOFToken
    result
  consume: (s) ->
    s.backtrack
      try: =>
        @semantic(@a.consume(s))
      fallback: =>
        @semantic(undefined)
  semantic: Id
  toString: ->
    "[#{@a}]?"

# semantic = (a,b) -> [a,b]
class GR.Juxtaposition extends GR.Grammar
  constructor: (@a, @b, @semantic = @semantic) ->
  consume: (s) ->
    x = @a.consume(s)
    s.optionalWhitespace()
    y = @b.consume(s)
    @semantic(x,y)
  toString: ->
    "[#{@a}] [#{@b}]"
    
# semantic = (a,b) -> [a,b]
class GR.CloselyJuxtaposed extends GR.Grammar
  constructor: (@a, @b, @semantic = @semantic) ->
    assert.function {@semantic}
  consume: (s) ->
    x = @a.consume(s)
    y = @b.consume(s)
    @semantic(x,y)
  toString: ->
    "[#{@a}]~[#{@b}]"

# semantic = (a) -> a
class GR.ExclusiveOr extends GR.Grammar
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
            # 
            if e.stream is s and f.stream is s
              throw e.merge(f)
            # If one of the branches went into a sub-stream, it means some level of success,
            # so we report the error from that branch.
            else if e.stream is s
              throw f
            else if f.stream is s
              throw e
            else
              # If both branches made it into the same sub-stream, it means that we can merge them
              # FIXME we don't know if they are in the same branch
              throw e.merge(f)
  semantic: Id
  toString: ->
    "[#{@a}]|[#{@b}]"

class GR.And extends GR.Grammar
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
  toString: ->
    "[#{@a}]&&[#{@b}]"

class GR.InclusiveOr extends GR.Grammar
  constructor: (@a, @b, @semantic = @semantic) ->
  consume: (s) ->
    new GR.ExclusiveOr(new GR.Juxtaposition(@a,new GR.Optional(@b),@semantic),
            new GR.Juxtaposition(@b,new GR.Optional(@a),Swap(@semantic))).consume(s)
  semantic: Cons
  toString: ->
    "[#{@a}]||[#{@b}]"


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

class GR.Range extends GR.Grammar
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
  toString: ->
    "[#{@a}]{#{@n},#{@m}}"

class GR.ZeroOrMore extends GR.Range
  constructor: (@a,@semantic = @semantic) ->
    @n = 0
    @m = Infinity
  toString: ->
    "[#{@a}]*"

class GR.OneOrMore extends GR.Range
  constructor: (@a,@semantic = @semantic) ->
    @n = 1
    @m = Infinity
  toString: ->
    "[#{@a}]+"

class GR.DelimitedBy extends GR.Grammar
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
  toString: ->
    "[#{@a}] [[#{@delim}] [#{@a}]]*"

class GR.DelimitedByComma extends GR.DelimitedBy
  constructor: (@a, @semantic = @semantic) ->
    @delim = new GR.Comma
  toString: ->
    "[#{@a}]#"



# This class does not affect the parsing, it only keeps track of a marking
# of the annotations directly (without another GR.Annotation in between) below
# this node.
class GR.AnnotationRoot extends GR.Grammar
  semantic: Id
  hasAnnotations: false
  constructor: (@a, @semantic = @semantic) ->
    @markings = []
    @prepareMarkings(@a)
  prepareMarkings: (node) ->
    if node instanceof GR.AnnotationRoot
      if node instanceof GR.Annotation
        @hasAnnotations = true
        node.root = @
      node.prepareMarkings(node.a)
    else
      if node.a
        @prepareMarkings(node.a)
      if node.b
        @prepareMarkings(node.b)
  toString: ->
    "#{@a}"
    
  # This parses the tree as usual, but also passes a marking
  # to the semantic function. The marking maps the names of the direct descendant
  # annotations to their subtree.
  parseWithAnnotations: (s) ->
    @markings.push {}
    try
      # `a.consume(s)` will add markings to `@markings`
      result = @a.consume(s)
      @semantic result, @markings[@markings.length-1]
    finally
      @markings.pop()

  setMarking: (name, value) ->
    @markings[@markings.length-1][name] = value

  consume: (s) ->
    if @hasAnnotations
      @parseWithAnnotations(s)
    else
      @semantic @a.consume(s)

# This node represents the `x:` annotations in the type tree.
# This is a subclass of  GR.AnnotationRoot, as the annotations below this
# will collect their markings here.
class GR.Annotation extends GR.AnnotationRoot
  root: undefined
  constructor: (@name, @a, @semantic = @semantic) ->
    @markings = []
  consume: (s) ->
    if @root
      # Here we add the marking to the closest GR.AnnotationRoot in the parent chain.
      @root.setMarking @name, if @hasAnnotations
        @parseWithAnnotations(s)
      else
        @semantic @a.consume(s)
    else
      throw new Error "GR.Annotation used without an GR.AnnotationRoot correctly configured"
  toString: ->
    "#{@name}:[#{@a}]"


# block types - these simply match a block, with the interior matching the given type
class GR.SimpleBlock extends GR.Grammar
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
  toString: ->
    "#{new @tokenClass} #{@a} #{new((new @tokenClass).mirror())}"

# A special type that refers to another type.
class GR.TypeReference extends GR.Grammar
  semantic: Id
  constructor: (@name, @quoted = no, @semantic = @semantic) ->
    @expected = @name
  consume: (s) ->
    if ! @fs
      throw new Error "Internal error in FunCSS: fs is not set up correctly"
    type = if @quoted then @fs.getPropertyType(@name) else @fs.getType(@name)
    pos = s.position
    try
      type.consume(s)
    catch e
      if e instanceof GR.NoMatch and e.stream is s and e.position is pos
        throw new GR.NoMatch(@expected, e.found, s, pos)
      else
        throw e
  toString: ->
    "<#{if @quoted then JSON.stringify(@name) else @name}>"


class GR.FunctionalNotation extends GR.Grammar
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
  toString: ->
    "#{@name}(#{@a})"

class GR.AnyFunctionalNotation extends GR.Grammar
  expected: "function"
  semantic: (name, x) -> throw Error "No semantic function for GR.AnyFunctionalNotation"
  constructor: (@a, @semantic = @semantic) ->
  consume: (s) ->
    next = s.next()
    unless next instanceof SS.Function
      s.noMatchNext(@expected)
    s.consume_next()
    return @semantic next.name, @a.parse(next.value, ")")
  toString: ->
    "<-funcss-any-functional-notation>"

class GR.RawTokens extends GR.Grammar
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
  toString: ->
    "<-funcss-raw-tokens>"

# This does not touch the input stream, just calls the semantic function
class GR.Empty extends GR.Grammar
  semantic: ->
  consume: (s) -> @semantic()
  toString: -> ""

# This is a pass-through grammar, it can be used to add an additional semantic function.
class GR.Just extends GR.Grammar
  semantic: Id
  constructor: (@a, @semantic = @semantic) ->
  consume: (s) -> @semantic @a.consume(s)
  toString: ->
    "#{@a}"

