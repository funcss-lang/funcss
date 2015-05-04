# This is an addition to the Parser grammar: a list of statements. This is another
# entry point for the grammar. Just like `parse_list_of_declarations`, this is a set of
# elements separated by semicolons. The difference is that it does not need to start
# with an ident and a colon.
#
# Lists of statements can include at-rules.
#

Parser = require "./parser"
SS = require "./ss_nodes"

class SS.Statement
  constructor : (@value) ->
class SS.StatementList
  @prototype: []

Parser.constructor.prototype[k] = v for k,v of {
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
          list = [@current]
          @consume_next()
          while not (@current instanceof SS.SemicolonToken or @current instanceof SS.EOFToken)
            list.push @current
            @consume_next()
          temp_stream = @stream
          try
            @stream = list
            @consume_next()
            statement = @consume_a_statement()
          finally
            @stream = temp_stream
          if statement?
            result.push statement

  consume_a_statement: () ->
    value = new SS.ComponentValueList
    value.push @current
    @consume_next()
    until @current instanceof SS.EOFToken
      # Unlike definitions, statements are parsed component value lists.
      @reconsume_current()
      value.push @consume_component_value()
      @consume_next()
    # TODO !important check
    return new SS.Statement(value, false)
}
