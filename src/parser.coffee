Tokenizer = require("#{__dirname}/tokenizer")
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

class AtRule
  constructor : (name, prelude, value = undefined) ->
    @name = name
    @prelude = prelude
    @value = value
class QualifiedRule
  constructor : (prelude, value = undefined) ->
    @prelude = prelude
    @value = value
class Declaration
  constructor : (name, value, important = false) ->
    @name = name
    @value = value
    @important = important
class Function
  constructor : (name, value) ->
    @name = name
    @value = value
class SimpleBlock
  constructor : (token, value) ->
    @token = token
    @value = value




class Parser
  init: (tokens) ->
    @stream = [t for t in tokens]
    @current = undefined

  consume_next: ->
    if @stream.length
      @current = @stream.shift()
    else
      @current = "EOF"

  next: ->
    if @stream.length
      @stream[0]
    else
      "EOF"


  parseStylesheet: (tokens) ->
    @init(tokens)
    return new Stylesheet(@consume_list_of_rules(true))


  parseListOfRules: (tokens) ->
    @init(tokens)
    return @consume_list_of_rules(false)

  parseRule: (tokens) ->
    @init(tokens)
    @consume_next()
    while @current instanceof WhitespaceToken
      @consume_next()
    if @current instanceof EOFToken
      return "syntax error"
    if @current instanceof AtKeywordToken
      result = @consume_at_rule()
    else
      result = @consume_qualified_rule()
      if not result?
        return "syntax error"
    while @current instanceof WhitespaceToken
      @consume_next()
    if @current instanceof EOFToken
      return result
    return "syntax error"


  parseDeclaration: (tokens) ->
    #> Note: Unlike "Parse a list of declarations", this parses only a declaration and not an at-rule.
    @init(tokens)
    @consume_next()
    while @current instanceof WhitespaceToken
      @consume_next()
    unless @current instanceof IdentToken
      return "syntax error"
    result = @consume_a_declaration
    if result?
      return result
    else
      return "syntax error"
    


  parseListOfDeclarations: (tokens) ->
    #> Note: Despite the name, this actually parses a mixed list of declarations and at-rules, as CSS 2.1 does for @page. Unexpected at-rules (which could be all of them, in a given context) are invalid and should be ignored by the consumer.
    @init(tokens)
    return @consume_list_of_declarations()

  parseComponentValue: (tokens) ->
    @init(tokens)
    @consume_next()
    while @current instanceof WhitespaceToken
      @consume_next()
    if @current instanceof EOFToken
      return "syntax error"
    @reconsume_current()
    value = @consume_component_value()
    if not value?
      return "syntax error"
    while @current instanceof WhitespaceToken
      @consume_next()
    if @current instanceof EOFToken
      return value
    else
      return "syntax error"



  parseListOfComponentValues: (tokens) ->
    @init(tokens)
    result = []
    value = @consume_component_value()
    until value instanceof EOFToken
      result.push value
      value = @consume_component_value()
    return result

  consume_list_of_rules: (toplevel) ->
    result = []
    while true
      @consume_next()
      switch
        when @current instanceof WhitespaceToken
        when @current instanceof EOFToken
          return result
        when @current instanceof CDOToken or @current instanceof CDCToken
          if toplevel
          else
            @reconsume_current()
            rule = @consume_qualified_rule()
            if rule?
              result.push rule
        when @current instanceof AtKeywordToken
          rule = @consume_at_rule()
          if rule?
            result.push rule
        else
          @reconsume_current()
          rule = @consume_qualified_rule()
          if rule?
            result.push rule

  consume_at_rule: ()->
    name = @current.value
    prelude = []
    while true
      @consume_next()
      switch
        when @current instanceof SemicolonToken or @current instanceof EOFToken
          return new AtRule(name, prelude)
        when @current instanceof OpeningCurlyToken
          block = @consume_simple_block()
          return new AtRule(name, prelude, block)
        when @current instanceof SimpleBlock and @current.token is OpeningCurlyToken
          return new AtRule(name, prelude, @current)
        else
          @reconsume_current()
          prelude.push @consume_component_value()

  consume_qualified_rule: () ->
    prelude = []
    while true
      @consume_next()
      switch
        when @current instanceof EOFToken
          return
        when @current instanceof OpeningCurlyToken
          block = @consume_simple_block()
          return new QualifiedRule(prelude, block)
        when @current instanceof SimpleBlock and @current.token is OpeningCurlyToken
          return new QualifiedRule(prelude, @current)
        else
          @reconsume_current()
          prelude.push @consume_component_value()

  consume_list_of_declarations: () ->
    result = []
    while true
      @consume_next()
      switch
        when @current instanceof WhitespaceToken or @current instanceof SemicolonToken
          # do nothing
        when @current instanceof EOFToken
          return result
        when @current instanceof AtKeywordToken
          result.push @consume_at_rule()
        when @current instanceof IdentToken
          list = [@current]
          @consume_next()
          while not (@current instanceof SemicolonToken or @current instanceof EOFToken)
            list.push @current
            @consume_next
          temp_stream = @stream
          try
            @stream = list
            declaration = @consume_a_declaration()
          finally
            @stream = temp_stream
          if declaration?
            result.push declaration
        else
          while (c = @consume_component_value()) instanceof SemicolonToken or c instanceof EOFToken
            # do nothing

  consume_a_declaration: () ->
    name = @current
    value =[]
    @consume_next()
    while @current instanceof WhitespaceToken
      @consume_next()
    unless @current instanceof ColonToken
      return null
    @consume_next()
    until @current instanceof EOFToken
      value.push @current
      @consume_next()
    # TODO !important check
    return new Declaration(name, value, false)

  consume_component_value: () ->
    @consume_next()
    if @current instanceof OpeningCurlyToken or @current instanceof OpeningSquareToken or @current instanceof OpeningParenToken
      return @consume_simple_block()
    if @current instanceof FunctionToken
      return @consume_function()
    return @current

  consume_simple_block: () ->
    starting = @current
    ending = @current instanceof OpeningCurlyToken ? ClosingCurlyToken : @current instanceof OpeningSquareToken ? ClosingSquareToken : ClosingParenToken
    value = []
    while true
      @consume_next()
      switch
        when @current instanceof EOFToken or @current instanceof ending
          return new SimpleBlock(starting, value)
        else
          @reconsume_current()
          value.push @consume_component_value()

  consume_function: () ->
    name = @current.value
    value = []
    while true
      @consume_next()
      switch
        when @current instanceof EOFToken or @current instanceof ClosingParenToken
          return new FunctionToken(name, value)
        else
          @reconsume_current()
          value.push @consume_component_value()





          
        












