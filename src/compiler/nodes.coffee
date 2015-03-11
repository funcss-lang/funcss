# This file contains the nodes used in the abstract syntax tree: tokens
#


class exports.IdentToken
  constructor : (@value) ->
  toString : -> @value
class exports.FunctionToken
  constructor : (@value) ->
  toString : -> @value + "("
class exports.AtKeywordToken
  constructor : (@value) ->
  toString : -> "@" + @value
class exports.HashToken
  constructor : (@value, @type = "unrestricted") ->
  toString : -> "#" + @value
class exports.StringToken
  constructor : (@value) ->
  toString : -> JSON.stringify(@value)
class exports.BadStringToken
class exports.UrlToken
  constructor : (@value) ->
  toString : -> "url(" + JSON.stringify(@value) + ")"
class exports.BadUrlToken
class exports.DelimToken
  constructor : (@value) ->
class exports.NumberToken
  constructor : (@repr, @value, @type = "integer") ->
  toString : -> @repr
class exports.PercentageToken
  constructor : (@repr, @value) ->
  toString : -> @repr+"%"
class exports.DimensionToken
  constructor : (@repr, @value, @type = "integer", @unit) ->
  toString : -> @repr+@unit
class exports.UnicodeRangeToken
  constructor : (@start, @end) ->
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

#### Parser output nodes
# These nodes come from the parser

class exports.AtRule
  constructor : (@name, @prelude, @value = undefined) ->
class exports.QualifiedRule
  constructor : (@prelude, @value = undefined) ->
class exports.Declaration
  constructor : (@name, @value, @important = false) ->
class exports.Function
  constructor : (@name, @value) ->
class exports.SimpleBlock
  constructor : (@token, @value) ->
class exports.SyntaxError

class exports.RuleList
  @prototype: []
class exports.DeclarationList
  @prototype: []
class exports.ComponentValueList
  @prototype: []
  @commentNeeded :
    IdentToken:
      IdentToken: yes
      FunctionToken: yes
      UrlToken: yes
      BadUrlToken: yes
      '-': yes
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
      UnicodeRangeToken: yes
      CDCToken: yes
      OpeningParenToken: yes
    AtKeywordToken:
      IdentToken: yes
      FunctionToken: yes
      UrlToken: yes
      BadUrlToken: yes
      '-': yes
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
      UnicodeRangeToken: yes
      CDCToken: yes
    HashToken:
      IdentToken: yes
      FunctionToken: yes
      UrlToken: yes
      BadUrlToken: yes
      '-': yes
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
      UnicodeRangeToken: yes
      CDCToken: yes
    DimensionToken:
      IdentToken: yes
      FunctionToken: yes
      UrlToken: yes
      BadUrlToken: yes
      '-': yes
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
      UnicodeRangeToken: yes
      CDCToken: yes
    '#':
      IdentToken: yes
      FunctionToken: yes
      UrlToken: yes
      BadUrlToken: yes
      '-': yes
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
      UnicodeRangeToken: yes
    '-':
      IdentToken: yes
      FunctionToken: yes
      UrlToken: yes
      BadUrlToken: yes
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
      UnicodeRangeToken: yes
    NumberToken:
      IdentToken: yes
      FunctionToken: yes
      UrlToken: yes
      BadUrlToken: yes
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
      UnicodeRangeToken: yes
    '@':
      IdentToken: yes
      FunctionToken: yes
      UrlToken: yes
      BadUrlToken: yes
      '-': yes
      UnicodeRangeToken: yes
    UnicodeRangeToken:
      IdentToken: yes
      FunctionToken: yes
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
      '?': yes
    '.':
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
    '+':
      NumberToken: yes
      PercentageToken: yes
      DimensionToken: yes
    '$':
      '=': yes
    '*':
      '=': yes
    '^':
      '=': yes
    '~':
      '=': yes
    '|':
      '=': yes
      '|': yes
    '/':
      '*': yes
  toString: ->
    
class exports.Stylesheet
  constructor : (@value) ->


