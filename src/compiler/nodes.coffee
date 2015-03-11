# This file contains the nodes used in the abstract syntax tree: tokens
#


class exports.IdentToken
  constructor : (value) ->
    @value = value
  toString : ->
    @value
class exports.FunctionToken
  constructor : (value) ->
    @value = value
  toString : ->
    @value + "("
class exports.AtKeywordToken
  constructor : (value) ->
    @value = value
  toString : ->
    "@" + @value
class exports.HashToken
  constructor : (value, type) ->
    @value = value
    @type = type ? "unrestricted"
  toString : ->
    "#" + @value
class exports.StringToken
  constructor : (value) ->
    @value = value
  toString : ->
    JSON.stringify(@value)
class exports.BadStringToken
class exports.UrlToken
  constructor : (value) ->
    @value = value
  toString : ->
    "url(" + JSON.stringify(@value) + ")"
class exports.BadUrlToken
class exports.DelimToken
  constructor : (value) ->
    @value = value
class exports.NumberToken
  constructor : (repr, value, type) ->
    @repr = repr
    @value = value
    @type = type ? "integer"
  toString : ->
    @repr
class exports.PercentageToken
  constructor : (repr, value) ->
    @repr = repr
    @value = value
  toString : ->
    @repr+"%"
class exports.DimensionToken
  constructor : (repr, value, type, unit) ->
    @repr = repr
    @value = value
    @type = type ? "integer"
    @unit = unit
  toString : ->
    @repr+@unit
class exports.UnicodeRangeToken
  constructor : (start, end) ->
    @start = start
    @end = end
class exports.IncludeMatchToken
  toString: -> "~="
class exports.DashMatchToken
  toString: -> "|="
class exports.PrefixMatchToken
  toString: -> "^="
class exports.SuffixMatchToken
  toString: -> "$="
class exports.SubstringMatchToken
  toString: -> "*="
class exports.ColumnToken
  toString: -> "||"
class exports.WhitespaceToken
  toString: -> " "
class exports.CDOToken
  toString: -> "<!--"
class exports.CDCToken
  toString: -> "-->"
class exports.ColonToken
  toString: -> ":"
class exports.SemicolonToken
  toString: -> ";"
class exports.CommaToken
  toString: -> ","
class exports.OpeningSquareToken
  toString: -> "["
class exports.ClosingSquareToken
  toString: -> "]"
class exports.OpeningParenToken
  toString: -> "("
class exports.ClosingParenToken
  toString: -> ")"
class exports.OpeningCurlyToken
  toString: -> "{"
class exports.ClosingCurlyToken
  toString: -> "}"
class exports.EOFToken
  toString: -> ""

# ## Parser output nodes
# These nodes come from the parser

class exports.AtRule
  constructor : (name, prelude, value = undefined) ->
    @name = name
    @prelude = prelude
    @value = value
class exports.QualifiedRule
  constructor : (prelude, value = undefined) ->
    @prelude = prelude
    @value = value
class exports.Declaration
  constructor : (name, value, important = false) ->
    @name = name
    @value = value
    @important = important
class exports.Function
  constructor : (name, value) ->
    @name = name
    @value = value
class exports.SimpleBlock
  constructor : (token, value) ->
    @token = token
    @value = value
class exports.SyntaxError
class exports.Stylesheet
  constructor : (value) ->
    @value = value


