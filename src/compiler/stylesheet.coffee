# This file contains the nodes used in the abstract syntax tree
#


#### Tokenizer nodes
#
# These are the tokens produced by the tokenizer.
#

exports.Token = class Token

exports.IdentToken = class IdentToken extends Token
  constructor : (@value) ->
  toString : -> @value
exports.FunctionToken = class FunctionToken extends Token
  constructor : (@value) ->
  toString : -> @value + "("
exports.AtKeywordToken = class AtKeywordToken extends Token
  constructor : (@value) ->
  toString : -> "@" + @value
exports.HashToken = class HashToken extends Token
  constructor : (@value, @type = "unrestricted") ->
  toString : -> "#" + @value
exports.StringToken = class StringToken extends Token
  constructor : (@value) ->
  toString : -> JSON.stringify(@value)
exports.BadStringToken = class BadStringToken extends Token
exports.UrlToken = class UrlToken
  constructor : (@value) ->
  toString : -> "url(" + JSON.stringify(@value) + ")"
exports.BadUrlToken = class BadUrlToken extends Token
exports.DelimToken = class DelimToken extends Token
  constructor : (@value) ->
  toString : -> @value
exports.NumberToken = class NumberToken extends Token
  constructor : (@repr, @value, @type = "integer") ->
  toString : -> @repr
exports.PercentageToken = class PercentageToken extends Token
  constructor : (@repr, @value) ->
  toString : -> @repr+"%"
exports.DimensionToken = class DimensionToken extends Token
  constructor : (@repr, @value, @type = "integer", @unit) ->
  toString : -> @repr+@unit
exports.UnicodeRangeToken = class UnicodeRangeToken extends Token
  constructor : (@start, @end) ->

##### Simple delim-like tokens
# These tokens have a single representation

exports.SimpleToken = class SimpleToken extends Token

exports.IncludeMatchToken = class IncludeMatchToken extends SimpleToken
  toString: -> "~="
exports.DashMatchToken = class DashMatchToken extends SimpleToken
  toString: -> "|="
exports.PrefixMatchToken = class PrefixMatchToken extends SimpleToken
  toString: -> "^="
exports.SuffixMatchToken = class SuffixMatchToken extends SimpleToken
  toString: -> "$="
exports.SubstringMatchToken = class SubstringMatchToken extends SimpleToken
  toString: -> "*="
exports.ColumnToken = class ColumnToken extends SimpleToken
  toString: -> "||"
exports.WhitespaceToken = class WhitespaceToken extends SimpleToken
  toString: -> " "
exports.CDOToken = class CDOToken extends SimpleToken
  toString: -> "<!--"
exports.CDCToken = class CDCToken extends SimpleToken
  toString: -> "-->"
exports.ColonToken = class ColonToken extends SimpleToken
  toString: -> ":"
exports.SemicolonToken = class SemicolonToken extends SimpleToken
  toString: -> ";"
exports.CommaToken = class CommaToken extends SimpleToken
  toString: -> ","

##### Block tokens
# These tokens are the block separators. The opening versions have a `mirror()` instance
# function which return the constructor of the closing version.

exports.OpeningSquareToken = class OpeningSquareToken extends Token
  toString: -> "["
  mirror: -> ClosingSquareToken
exports.ClosingSquareToken = class ClosingSquareToken extends Token
  toString: -> "]"
exports.OpeningParenToken = class OpeningParenToken extends Token
  toString: -> "("
  mirror: -> ClosingParenToken
exports.ClosingParenToken = class ClosingParenToken extends Token
  toString: -> ")"
exports.OpeningCurlyToken = class OpeningCurlyToken extends Token
  toString: -> "{"
  mirror: -> ClosingCurlyToken
exports.ClosingCurlyToken = class ClosingCurlyToken extends Token
  toString: -> "}"
exports.EOFToken = class EOFToken
  toString: -> ""

#### Parser output nodes
# These nodes are created by the parser
#
# The parser in FunCSS needs to be exactly the same as the CSS parser 
# (Except for tokens that are not in the CSS standard.) Any FunCSS-specific
# modification needs to be coded in the upper levels, e.g. in the value 
# definitions.

exports.AtRule = class AtRule
  constructor : (@name, @prelude, @value = undefined) ->
  toString: ->
    "@#{@name}#{@prelude}#{@value ? ';'}"
exports.QualifiedRule = class QualifiedRule
  constructor : (@prelude, @value = undefined) ->
  toString: ->
    "#{@prelude} { #{@value?.value ? ''} }"
exports.Declaration = class Declaration
  constructor : (@name, @value, @important = false) ->
exports.Function = class Function
  constructor : (@name, @value) ->
  toString : ->
    "#{@name}(#{@value})"
exports.SimpleBlock = class SimpleBlock
  constructor : (@token, @value) ->
  toString : ->
    "#{@token}#{@value}#{new(@token.mirror())}"
exports.SyntaxError = class SyntaxError

##### List classes
# These classes inherit from Array.
  
  
exports.RuleList = class RuleList
  @prototype: []
exports.DeclarationList = class DeclarationList
  @prototype: []
exports.ComponentValueList = class ComponentValueList
  @prototype: []
  # This table is the copy of the one in the CSS Syntax Level 3 CR spec.
  @commentNeededMap :
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
      '(': yes
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
  @commentNeeded : (node1, node2) ->
    [name1, name2] = for node in arguments
      # Here we do some renaming to help the lookup in the table above.

      # First, if the node is not a token but a parser-generated node which
      # can occur in a component value list (namely, SimpleBlock or Function),
      # we use its starting token.
      if node instanceof SimpleBlock
        node = node.token
      else if node instanceof Function
        node = new FunctionToken(node.name)

      # Then for delimiters and (-tokens, we use the string representation,
      # for others we use the token name (like in the spec)
      
      name = if node instanceof DelimToken
        node.value
      else if node instanceof OpeningParenToken
        '('
      else
        node.constructor.name
    !! @commentNeededMap[name1]?[name2]
  toString: ->
    result = for node,i in @
      if i>0 and i<@length and ComponentValueList.commentNeeded(@[i-1],node)
        "/**/" + node
      else
        node
    result.join('')

      
    
exports.Stylesheet = class Stylesheet
  constructor : (@value) ->
  toString: ->
    @value.join("\n")

