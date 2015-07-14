## The Stylesheet nodes
#
# These nodes are used in the abstract syntax tree of FunCSS. They are
# the same as the CSS AST nodes, according to CSS-SYNTAX level 3.
# 
# *Outputs*
#
# - `toString()` returns a string which is a good serialization of the AST.
#


#### Tokenizer nodes
#
# These are the tokens produced by the tokenizer.
#
#

SS = exports

class SS.Token

class SS.IdentToken extends SS.Token
  constructor : (@value) ->
  toString : -> @value
class SS.FunctionToken extends SS.Token
  constructor : (@value) ->
  toString : -> @value + "("
class SS.AtKeywordToken extends SS.Token
  constructor : (@value) ->
  toString : -> "@" + @value
class SS.HashToken extends SS.Token
  constructor : (@value, @type = "unrestricted") ->
  toString : -> "#" + @value
class SS.StringToken extends SS.Token
  constructor : (@value) ->
  toString : -> JSON.stringify(@value)
class SS.BadStringToken extends SS.Token
class SS.UrlToken
  constructor : (@value) ->
  toString : -> "url(" + JSON.stringify(@value) + ")"
class SS.BadUrlToken extends SS.Token
class SS.DelimToken extends SS.Token
  constructor : (@value) ->
  toString : -> @value
class SS.NumberToken extends SS.Token
  constructor : (@repr, @value, @type = "integer") ->
  toString : -> @repr
class SS.PercentageToken extends SS.Token
  constructor : (@repr, @value) ->
  toString : -> @repr+"%"
class SS.DimensionToken extends SS.Token
  constructor : (@repr, @value, @type = "integer", @unit) ->
  toString : -> @repr+@unit
class SS.UnicodeRangeToken extends SS.Token
  constructor : (@start, @end) ->

##### Simple delim-like tokens
# These tokens have a single representation

class SS.SimpleToken extends SS.Token

class SS.IncludeMatchToken extends SS.SimpleToken
  toString: -> "~="
class SS.DashMatchToken extends SS.SimpleToken
  toString: -> "|="
class SS.PrefixMatchToken extends SS.SimpleToken
  toString: -> "^="
class SS.SuffixMatchToken extends SS.SimpleToken
  toString: -> "$="
class SS.SubstringMatchToken extends SS.SimpleToken
  toString: -> "*="
class SS.ColumnToken extends SS.SimpleToken
  toString: -> "||"
class SS.WhitespaceToken extends SS.SimpleToken
  toString: -> " "
class SS.CDOToken extends SS.SimpleToken
  toString: -> "<!--"
class SS.CDCToken extends SS.SimpleToken
  toString: -> "-->"
class SS.ColonToken extends SS.SimpleToken
  toString: -> ":"
class SS.SemicolonToken extends SS.SimpleToken
  toString: -> ";"
class SS.CommaToken extends SS.SimpleToken
  toString: -> ","

##### Block tokens
# These tokens are the block separators. The opening versions have a `mirror()` instance
# function which return the constructor of the closing version.

class SS.OpeningSquareToken extends SS.SimpleToken
  toString: -> "["
  mirror: -> SS.ClosingSquareToken
class SS.ClosingSquareToken extends SS.SimpleToken
  toString: -> "]"
class SS.OpeningParenToken extends SS.SimpleToken
  toString: -> "("
  mirror: -> SS.ClosingParenToken
class SS.ClosingParenToken extends SS.SimpleToken
  toString: -> ")"
class SS.OpeningCurlyToken extends SS.SimpleToken
  toString: -> "{"
  mirror: -> SS.ClosingCurlyToken
class SS.ClosingCurlyToken extends SS.SimpleToken
  toString: -> "}"
class SS.EOFToken
  constructor: (@nextToken = "") ->
  toString: -> @nextToken

#### Parser output nodes
# These nodes are created by the parser
#
# The parser in FunCSS needs to be exactly the same as the CSS parser 
# (Except for tokens that are not in the CSS standard.) Any FunCSS-specific
# modification needs to be coded in the upper levels, e.g. in the value 
# definitions.

class SS.AtRule
  constructor : (@name, @prelude, @value = undefined) ->
  toString: ->
    "@#{@name}#{@prelude}#{@value ? ';'}"
class SS.QualifiedRule
  constructor : (@prelude, @value = undefined) ->
  toString: ->
    "#{@prelude} { #{@value?.value ? ''} }"
class SS.Declaration
  constructor : (@name, @value, @important = false) ->
class SS.Function
  constructor : (@name, @value) ->
  toString : ->
    "#{@name}(#{@value})"
class SS.SimpleBlock
  constructor : (@token, @value) ->
  toString : ->
    "#{@token}#{@value}#{new(@token.mirror())}"
class SS.SyntaxError

##### List classes
# These classes inherit from Array.
  
  
class SS.RuleList
  @prototype: []
class SS.DeclarationList
  @prototype: []
class SS.ComponentValueList
  @prototype: []
  # This table is the copy of the one in the CSS Syntax Level 3 CR spec. It is used
  # for deciding whether a comment is needed between two tokens when serializing.
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
      # can occur in a component value list (namely, SS.SimpleBlock or SS.Function),
      # we use its starting token.
      if node instanceof SS.SimpleBlock
        node = node.token
      else if node instanceof SS.Function
        node = new SS.FunctionToken(node.name)

      # Then for delimiters and (-tokens, we use the string representation,
      # for others we use the token name (like in the spec)
      
      name = if node instanceof SS.DelimToken
        node.value
      else if node instanceof SS.OpeningParenToken
        '('
      else
        node.constructor.name
    !! @commentNeededMap[name1]?[name2]
  toString: ->
    result = for node,i in @
      if i>0 and i<@length and SS.ComponentValueList.commentNeeded(@[i-1],node)
        "/**/" + node
      else
        node
    result.join('')

      
    
class SS.Stylesheet
  constructor : (@value) ->
  toString: ->
    @value.join("\n")

