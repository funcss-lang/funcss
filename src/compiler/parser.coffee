Tokenizer = require "./tokenizer"
N = require "./nodes"



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
      @current = new N.EOFToken

  next: ->
    if @stream.length
      @stream[0]
    else
      new N.EOFToken

  reconsume_current: ->
    @stream.unshift(@current)


  parse_stylesheet: (tokens) ->
    @init(tokens)
    return new N.Stylesheet(@consume_list_of_rules(true))


  parse_list_of_rules: (tokens) ->
    @init(tokens)
    return @consume_list_of_rules(false)

  parse_rule: (tokens) ->
    @init(tokens)
    @consume_next()
    while @current instanceof N.WhitespaceToken
      @consume_next()
    if @current instanceof N.EOFToken
      return new N.SyntaxError
    if @current instanceof N.AtKeywordToken
      result = @consume_at_rule()
    else
      @reconsume_current()
      result = @consume_qualified_rule()
      if not result?
        return new N.SyntaxError
    @consume_next()
    while @current instanceof N.WhitespaceToken
      @consume_next()
    if @current instanceof N.EOFToken
      return result
    return new N.SyntaxError


  parse_declaration: (tokens) ->
    #> Note: Unlike "Parse a list of declarations", this parses only a N.declaration and not an at-rule.
    @init(tokens)
    @consume_next()
    while @current instanceof N.WhitespaceToken
      @consume_next()
    unless @current instanceof N.IdentToken
      return new N.SyntaxError
    result = @consume_a_declaration
    if result?
      return result
    else
      return new N.SyntaxError
    


  parse_list_of_declarations: (tokens) ->
    #> Note: Despite the name, this actually parses a mixed list of declarations and at-rules, as CSS 2.1 does for @page. Unexpected at-rules (which could be all of them, in a given context) are invalid and should be ignored by the consumer.
    @init(tokens)
    return @consume_list_of_declarations()

  parse_component_value: (tokens) ->
    @init(tokens)
    @consume_next()
    while @current instanceof N.WhitespaceToken
      @consume_next()
    if @current instanceof N.EOFToken
      return new N.SyntaxError
    @reconsume_current()
    value = @consume_component_value()
    if not value?
      return new N.SyntaxError
    @consume_next()
    while @current instanceof N.WhitespaceToken
      @consume_next()
    if @current instanceof N.EOFToken
      return value
    else
      return new N.SyntaxError



  parse_list_of_component_values: (tokens) ->
    @init(tokens)
    result = new N.ComponentValueList
    value = @consume_component_value()
    until value instanceof N.EOFToken
      result.push value
      value = @consume_component_value()
    return result

  consume_list_of_rules: (toplevel) ->
    result = new N.RuleList
    while true
      @consume_next()
      switch
        when @current instanceof N.WhitespaceToken
          "do nothing"
        when @current instanceof N.EOFToken
          return result
        when @current instanceof N.CDOToken or @current instanceof N.CDCToken
          if toplevel
          else
            @reconsume_current()
            rule = @consume_qualified_rule()
            if rule?
              result.push rule
        when @current instanceof N.AtKeywordToken
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
    prelude = new N.ComponentValueList
    while true
      @consume_next()
      switch
        when @current instanceof N.SemicolonToken or @current instanceof N.EOFToken
          return new N.AtRule(name, prelude)
        when @current instanceof N.OpeningCurlyToken
          block = @consume_simple_block()
          return new N.AtRule(name, prelude, block)
        when @current instanceof N.SimpleBlock and @current.token instanceof N.OpeningCurlyToken
          return new N.AtRule(name, prelude, @current)
        else
          @reconsume_current()
          prelude.push @consume_component_value()

  consume_qualified_rule: () ->
    prelude = new N.ComponentValueList
    while true
      @consume_next()
      switch
        when @current instanceof N.EOFToken
          return
        when @current instanceof N.OpeningCurlyToken
          block = @consume_simple_block()
          return new N.QualifiedRule(prelude, block)
        when @current instanceof N.SimpleBlock and @current.token instanceof N.OpeningCurlyToken
          return new N.QualifiedRule(prelude, @current)
        else
          @reconsume_current()
          prelude.push @consume_component_value()

  consume_list_of_declarations: () ->
    result = new N.DeclarationList
    while true
      @consume_next()
      switch
        when @current instanceof N.WhitespaceToken or @current instanceof N.SemicolonToken
          "do nothing"
        when @current instanceof N.EOFToken
          return result
        when @current instanceof N.AtKeywordToken
          result.push @consume_at_rule()
        when @current instanceof N.IdentToken
          list = [@current]
          @consume_next()
          while not (@current instanceof N.SemicolonToken or @current instanceof N.EOFToken)
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
          while (c = @consume_component_value()) instanceof N.SemicolonToken or c instanceof N.EOFToken
            "do nothing"

  consume_a_declaration: () ->
    name = @current.value
    value = new N.ComponentValueList
    @consume_next()
    while @current instanceof N.WhitespaceToken
      @consume_next()
    unless @current instanceof N.ColonToken
      return null
    @consume_next()
    until @current instanceof N.EOFToken
      value.push @current
      @consume_next()
    # TODO !important check
    return new N.Declaration(name, value, false)

  consume_component_value: () ->
    @consume_next()
    if @current instanceof N.OpeningCurlyToken or @current instanceof N.OpeningSquareToken or @current instanceof N.OpeningParenToken
      return @consume_simple_block()
    if @current instanceof N.FunctionToken
      return @consume_function()
    return @current

  consume_simple_block: () ->
    starting = @current
    ending = starting.mirror()
    value = new N.ComponentValueList
    while true
      @consume_next()
      switch
        when @current instanceof N.EOFToken or @current instanceof ending
          return new N.SimpleBlock(starting, value)
        else
          @reconsume_current()
          value.push @consume_component_value()

  consume_function: () ->
    name = @current.value
    value = new N.ComponentValueList
    while true
      @consume_next()
      switch
        when @current instanceof N.EOFToken or @current instanceof N.ClosingParenToken
          return new N.Function(name, value)
        else
          @reconsume_current()
          value.push @consume_component_value()



module.exports = new Parser



          
        












