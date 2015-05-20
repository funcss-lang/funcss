# This is an addition to the Parser grammar: a list of statements. This is another
# entry point for the grammar. Just like `parse_list_of_declarations`, this is a set of
# elements separated by semicolons. The difference is that it does not need to start
# with an ident and a colon.
#
# Lists of statements can include at-rules.
#

Parser = require "./parser"
SS     = require "./ss_nodes"

class SS.Statement
  constructor : (@prelude, @block = undefined) ->
  toString: ->
    "#{@prelude}#{@block ? ';'}"
class SS.StatementList
  @prototype: []
  toString: -> @join("\n")

Parser.constructor.prototype[k] = v for k,v of {
  parse_a_statement: (tokens) ->
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
      result = @consume_a_statement()
      if not result?
        return new SS.SyntaxError
    @consume_next()
    while @current instanceof SS.WhitespaceToken
      @consume_next()
    if @current instanceof SS.EOFToken
      return result
    return new SS.SyntaxError

  parse_list_of_statements: (tokens) ->
    @init(tokens)
    return @consume_list_of_statements()

  consume_list_of_statements: () ->
    result = new SS.StatementList
    while true
      @consume_next()
      switch
        when @current instanceof SS.WhitespaceToken or @current instanceof SS.SemicolonToken
          "do nothing"
        when @current instanceof SS.EOFToken
          return result
        when @current instanceof SS.AtKeywordToken
          result.push @consume_at_rule()
        else
          @reconsume_current()
          statement = @consume_a_statement()
          if statement?
            result.push statement

  consume_a_statement: () ->
    prelude = new SS.ComponentValueList
    while true
      @consume_next()
      switch
        when @current instanceof SS.EOFToken or @current instanceof SS.SemicolonToken
          return new SS.Statement(prelude)
        when @current instanceof SS.OpeningCurlyToken
          block = @consume_simple_block()
          return new SS.Statement(prelude, block)
        when @current instanceof SS.SimpleBlock and @current.token instanceof SS.OpeningCurlyToken
          return new SS.Statement(prelude, @current)
        else
          @reconsume_current()
          prelude.push @consume_component_value()


}
