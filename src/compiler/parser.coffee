Tokenizer = require("#{__dirname}/tokenizer")

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
class SyntaxError
class Stylesheet
  constructor : (value) ->
    @value = value




class Parser
  init: (tokens) ->
    if typeof tokens is "string" or tokens instanceof String
      @stream = Tokenizer.tokenize(tokens)
    else
      @stream = (t for t in tokens)
    @current = undefined

  consume_next: ->
    if @stream.length
      @current = @stream.shift()
    else
      @current = new Tokenizer.EOFToken

  next: ->
    if @stream.length
      @stream[0]
    else
      new Tokenizer.EOFToken

  reconsume_current: ->
    @stream.unshift(@current)


  parse_stylesheet: (tokens) ->
    @init(tokens)
    return new Stylesheet(@consume_list_of_rules(true))


  parse_list_of_rules: (tokens) ->
    @init(tokens)
    return @consume_list_of_rules(false)

  parse_rule: (tokens) ->
    @init(tokens)
    @consume_next()
    while @current instanceof Tokenizer.WhitespaceToken
      @consume_next()
    if @current instanceof Tokenizer.EOFToken
      return new SyntaxError
    if @current instanceof Tokenizer.AtKeywordToken
      result = @consume_at_rule()
    else
      @reconsume_current()
      result = @consume_qualified_rule()
      if not result?
        return new SyntaxError
    @consume_next()
    while @current instanceof Tokenizer.WhitespaceToken
      @consume_next()
    if @current instanceof Tokenizer.EOFToken
      return result
    return new SyntaxError


  parse_declaration: (tokens) ->
    #> Note: Unlike "Parse a list of declarations", this parses only a declaration and not an at-rule.
    @init(tokens)
    @consume_next()
    while @current instanceof Tokenizer.WhitespaceToken
      @consume_next()
    unless @current instanceof Tokenizer.IdentToken
      return new SyntaxError
    result = @consume_a_declaration
    if result?
      return result
    else
      return new SyntaxError
    


  parse_list_of_declarations: (tokens) ->
    #> Note: Despite the name, this actually parses a mixed list of declarations and at-rules, as CSS 2.1 does for @page. Unexpected at-rules (which could be all of them, in a given context) are invalid and should be ignored by the consumer.
    @init(tokens)
    return @consume_list_of_declarations()

  parse_component_value: (tokens) ->
    @init(tokens)
    @consume_next()
    while @current instanceof Tokenizer.WhitespaceToken
      @consume_next()
    if @current instanceof Tokenizer.EOFToken
      return new SyntaxError
    @reconsume_current()
    value = @consume_component_value()
    if not value?
      return new SyntaxError
    @consume_next()
    while @current instanceof Tokenizer.WhitespaceToken
      @consume_next()
    if @current instanceof Tokenizer.EOFToken
      return value
    else
      return new SyntaxError



  parse_list_of_component_values: (tokens) ->
    @init(tokens)
    result = []
    value = @consume_component_value()
    until value instanceof Tokenizer.EOFToken
      result.push value
      value = @consume_component_value()
    return result

  consume_list_of_rules: (toplevel) ->
    result = []
    while true
      @consume_next()
      switch
        when @current instanceof Tokenizer.WhitespaceToken
          "do nothing"
        when @current instanceof Tokenizer.EOFToken
          return result
        when @current instanceof Tokenizer.CDOToken or @current instanceof Tokenizer.CDCToken
          if toplevel
          else
            @reconsume_current()
            rule = @consume_qualified_rule()
            if rule?
              result.push rule
        when @current instanceof Tokenizer.AtKeywordToken
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
        when @current instanceof Tokenizer.SemicolonToken or @current instanceof Tokenizer.EOFToken
          return new AtRule(name, prelude)
        when @current instanceof Tokenizer.OpeningCurlyToken
          block = @consume_simple_block()
          return new AtRule(name, prelude, block)
        when @current instanceof SimpleBlock and @current.token instanceof Tokenizer.OpeningCurlyToken
          return new AtRule(name, prelude, @current)
        else
          @reconsume_current()
          prelude.push @consume_component_value()

  consume_qualified_rule: () ->
    prelude = []
    while true
      @consume_next()
      switch
        when @current instanceof Tokenizer.EOFToken
          return
        when @current instanceof Tokenizer.OpeningCurlyToken
          block = @consume_simple_block()
          return new QualifiedRule(prelude, block)
        when @current instanceof SimpleBlock and @current.token instanceof Tokenizer.OpeningCurlyToken
          return new QualifiedRule(prelude, @current)
        else
          @reconsume_current()
          prelude.push @consume_component_value()

  consume_list_of_declarations: () ->
    result = []
    while true
      @consume_next()
      switch
        when @current instanceof Tokenizer.WhitespaceToken or @current instanceof Tokenizer.SemicolonToken
          "do nothing"
        when @current instanceof Tokenizer.EOFToken
          return result
        when @current instanceof Tokenizer.AtKeywordToken
          result.push @consume_at_rule()
        when @current instanceof Tokenizer.IdentToken
          list = [@current]
          @consume_next()
          while not (@current instanceof Tokenizer.SemicolonToken or @current instanceof Tokenizer.EOFToken)
            list.push @current
            @consume_next()
          temp_stream = @stream
          try
            @stream = list
            @consume_next()
            declaration = @consume_a_declaration()
          finally
            @stream = temp_stream
          if declaration?
            result.push declaration
        else
          while (c = @consume_component_value()) instanceof Tokenizer.SemicolonToken or c instanceof Tokenizer.EOFToken
            "do nothing"

  consume_a_declaration: () ->
    name = @current.value
    value =[]
    @consume_next()
    while @current instanceof Tokenizer.WhitespaceToken
      @consume_next()
    unless @current instanceof Tokenizer.ColonToken
      return null
    @consume_next()
    until @current instanceof Tokenizer.EOFToken
      value.push @current
      @consume_next()
    # TODO !important check
    return new Declaration(name, value, false)

  consume_component_value: () ->
    @consume_next()
    if @current instanceof Tokenizer.OpeningCurlyToken or @current instanceof Tokenizer.OpeningSquareToken or @current instanceof Tokenizer.OpeningParenToken
      return @consume_simple_block()
    if @current instanceof Tokenizer.FunctionToken
      return @consume_function()
    return @current

  consume_simple_block: () ->
    starting = @current
    ending = if @current instanceof Tokenizer.OpeningCurlyToken
      Tokenizer.ClosingCurlyToken
    else if @current instanceof Tokenizer.OpeningSquareToken
      Tokenizer.ClosingSquareToken
    else
      Tokenizer.ClosingParenToken
    value = []
    while true
      @consume_next()
      switch
        when @current instanceof Tokenizer.EOFToken or @current instanceof ending
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
        when @current instanceof Tokenizer.EOFToken or @current instanceof Tokenizer.ClosingParenToken
          return new Function(name, value)
        else
          @reconsume_current()
          value.push @consume_component_value()



module.exports = new Parser
for k,v of {
  AtRule
  QualifiedRule
  Declaration
  Function
  SimpleBlock
  SyntaxError
  Stylesheet
}
  module.exports[k] = v



          
        












