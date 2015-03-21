Tokenizer = require "./tokenizer"
SS = require "./stylesheet"



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
      @current = new SS.EOFToken

  next: ->
    if @stream.length
      @stream[0]
    else
      new SS.EOFToken

  reconsume_current: ->
    @stream.unshift(@current)


  parse_stylesheet: (tokens) ->
    @init(tokens)
    return new SS.Stylesheet(@consume_list_of_rules(true))


  parse_list_of_rules: (tokens) ->
    @init(tokens)
    return @consume_list_of_rules(false)

  parse_rule: (tokens) ->
    @init(tokens)
    @consume_next()
    while @current instanceof SS.WhitespaceToken
      @consume_next()
    if @current instanceof SS.EOFToken
      return new SS.SyntaxError
    if @current instanceof SS.AtKeywordToken
      result = @consume_at_rule()
    else
      @reconsume_current()
      result = @consume_qualified_rule()
      if not result?
        return new SS.SyntaxError
    @consume_next()
    while @current instanceof SS.WhitespaceToken
      @consume_next()
    if @current instanceof SS.EOFToken
      return result
    return new SS.SyntaxError


  parse_declaration: (tokens) ->
    #> Note: Unlike "Parse a list of declarations", this parses only a SS.declaration and not an at-rule.
    @init(tokens)
    @consume_next()
    while @current instanceof SS.WhitespaceToken
      @consume_next()
    unless @current instanceof SS.IdentToken
      return new SS.SyntaxError
    result = @consume_a_declaration
    if result?
      return result
    else
      return new SS.SyntaxError
    


  parse_list_of_declarations: (tokens) ->
    #> Note: Despite the name, this actually parses a mixed list of declarations and at-rules, as CSS 2.1 does for @page. Unexpected at-rules (which could be all of them, in a given context) are invalid and should be ignored by the consumer.
    @init(tokens)
    return @consume_list_of_declarations()

  parse_component_value: (tokens) ->
    @init(tokens)
    @consume_next()
    while @current instanceof SS.WhitespaceToken
      @consume_next()
    if @current instanceof SS.EOFToken
      return new SS.SyntaxError
    @reconsume_current()
    value = @consume_component_value()
    if not value?
      return new SS.SyntaxError
    @consume_next()
    while @current instanceof SS.WhitespaceToken
      @consume_next()
    if @current instanceof SS.EOFToken
      return value
    else
      return new SS.SyntaxError



  parse_list_of_component_values: (tokens) ->
    @init(tokens)
    result = new SS.ComponentValueList
    value = @consume_component_value()
    until value instanceof SS.EOFToken
      result.push value
      value = @consume_component_value()
    return result

  consume_list_of_rules: (toplevel) ->
    result = new SS.RuleList
    while true
      @consume_next()
      switch
        when @current instanceof SS.WhitespaceToken
          "do nothing"
        when @current instanceof SS.EOFToken
          return result
        when @current instanceof SS.CDOToken or @current instanceof SS.CDCToken
          if toplevel
          else
            @reconsume_current()
            rule = @consume_qualified_rule()
            if rule?
              result.push rule
        when @current instanceof SS.AtKeywordToken
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
    prelude = new SS.ComponentValueList
    while true
      @consume_next()
      switch
        when @current instanceof SS.SemicolonToken or @current instanceof SS.EOFToken
          return new SS.AtRule(name, prelude)
        when @current instanceof SS.OpeningCurlyToken
          block = @consume_simple_block()
          return new SS.AtRule(name, prelude, block)
        when @current instanceof SS.SimpleBlock and @current.token instanceof SS.OpeningCurlyToken
          return new SS.AtRule(name, prelude, @current)
        else
          @reconsume_current()
          prelude.push @consume_component_value()

  consume_qualified_rule: () ->
    prelude = new SS.ComponentValueList
    while true
      @consume_next()
      switch
        when @current instanceof SS.EOFToken
          return
        when @current instanceof SS.OpeningCurlyToken
          block = @consume_simple_block()
          return new SS.QualifiedRule(prelude, block)
        when @current instanceof SS.SimpleBlock and @current.token instanceof SS.OpeningCurlyToken
          return new SS.QualifiedRule(prelude, @current)
        else
          @reconsume_current()
          prelude.push @consume_component_value()

  consume_list_of_declarations: () ->
    result = new SS.DeclarationList
    while true
      @consume_next()
      switch
        when @current instanceof SS.WhitespaceToken or @current instanceof SS.SemicolonToken
          "do nothing"
        when @current instanceof SS.EOFToken
          return result
        when @current instanceof SS.AtKeywordToken
          result.push @consume_at_rule()
        when @current instanceof SS.IdentToken
          list = [@current]
          @consume_next()
          while not (@current instanceof SS.SemicolonToken or @current instanceof SS.EOFToken)
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
          while (c = @consume_component_value()) instanceof SS.SemicolonToken or c instanceof SS.EOFToken
            "do nothing"

  consume_a_declaration: () ->
    name = @current.value
    value = new SS.ComponentValueList
    @consume_next()
    while @current instanceof SS.WhitespaceToken
      @consume_next()
    unless @current instanceof SS.ColonToken
      return null
    @consume_next()
    until @current instanceof SS.EOFToken
      value.push @current
      @consume_next()
    # TODO !important check
    return new SS.Declaration(name, value, false)

  consume_component_value: () ->
    @consume_next()
    if @current instanceof SS.OpeningCurlyToken or @current instanceof SS.OpeningSquareToken or @current instanceof SS.OpeningParenToken
      return @consume_simple_block()
    if @current instanceof SS.FunctionToken
      return @consume_function()
    return @current

  consume_simple_block: () ->
    starting = @current
    ending = starting.mirror()
    value = new SS.ComponentValueList
    while true
      @consume_next()
      switch
        when @current instanceof SS.EOFToken or @current instanceof ending
          return new SS.SimpleBlock(starting, value)
        else
          @reconsume_current()
          value.push @consume_component_value()

  consume_function: () ->
    name = @current.value
    value = new SS.ComponentValueList
    while true
      @consume_next()
      switch
        when @current instanceof SS.EOFToken or @current instanceof SS.ClosingParenToken
          return new SS.Function(name, value)
        else
          @reconsume_current()
          value.push @consume_component_value()



module.exports = new Parser



          
        












