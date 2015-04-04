# This file contains the transformation rules (defined in terms of a Types tree)
# that transforms a type definition token stream to a Types tree. The result will
# transform an actual value token stream to an LLL value
#
TP = require "../../src/compiler/types"
SS = require "../../src/compiler/stylesheet"
LL = require "./lll"

TYPES = {}

# Helper functions
Id = Fst = (x) -> x
Snd = (_,y) -> y
Pair = (x,y) -> [x,y]
Cons = (x,y) -> y.unshift x; y

# Makes a chain of binary nodes. The last internal node will contain two leaves.
# If the list contains a single element, just returns it.
#
# `t` is the constructor of the binary type
#
# `opts` can have the following fields:
#
#  * `pair` the semantic function used for the constructor invocation with
#  the last two elements of the list
#  * `cons` the semantic function used for all other invocations
pairsOf = (t, list, opts = {}) ->
  if !list.length
    throw new Error "internal error in VDS: cannot make pairs of empty list or a non-list"
  if list.length is 1
    return list[0]
  if list.length is 2
    return new t(list[0], list[1], opts.pair)
  return new t(list[0], pairsOf(t, list[1..-1], opts), opts.cons)

# helpers
OpeningAngle = new TP.DelimLike(new SS.DelimToken('<'))
ClosingAngle = new TP.DelimLike(new SS.DelimToken('>'))
OpeningCurly = new TP.DelimLike(new SS.OpeningCurlyToken)
ClosingCurly = new TP.DelimLike(new SS.ClosingCurlyToken)
OpeningSquare= new TP.DelimLike(new SS.OpeningSquareToken)
ClosingSquare= new TP.DelimLike(new SS.ClosingSquareToken)
Colon        = new TP.DelimLike(new SS.ColonToken)
Ampersand    = new TP.DelimLike(new SS.DelimToken('&'))
DblAmpersand = new TP.CloselyJuxtaposed(Ampersand, Ampersand, ->)
Column       = new TP.DelimLike(new SS.ColumnToken)
Bar          = new TP.DelimLike(new SS.DelimToken('|'))
Comma        = new TP.DelimLike(new SS.CommaToken)


# helper types
Ident = new TP.Ident
Number = new TP.Number
Integer = new TP.Integer
Percentage = new TP.Percentage
String = new TP.String

# CSS separators
# Separators have a JS representation of their string value. This is useful when using it in
# a mapping, to decide whether the delimiter is there, or what delimiter is there.
# For example,
#
#   @fun f(a:<number> [comma:,|slash:/]? b:<number>) {
#     if (comma) {
#       ...
#     } else if (slash) {
#       ...
#     } else {
#       ...
#     }
#   }
LiteralSlash = new TP.DelimLike(new SS.DelimToken('/'), (x)->new TP.DelimLike(x, (x)->new LL.Keyword("/")))
LiteralComma = new TP.DelimLike(new SS.CommaToken, (x)->new TP.DelimLike(x, (x)->new LL.Keyword(",")))

# Multiplier tokens with metadata for easy handling
Hashmark     = new TP.DelimLike(new SS.DelimToken('#'), ->{multiplier: TP.DelimitedByComma})
Plus         = new TP.DelimLike(new SS.DelimToken('+'), ->{multiplier: TP.OneOrMore})
QuestionMark = new TP.DelimLike(new SS.DelimToken('?'), ->{multiplier: TP.Optional})
Asterisk     = new TP.DelimLike(new SS.DelimToken('*'), ->{multiplier: TP.ZeroOrMore})
# The {A,B} syntax for repetition count. Its semantic function returns a [1,3] format
RepeatCount =
  new TP.SimpleBlock SS.OpeningCurlyToken,
    new TP.CloselyJuxtaposed Integer,
      new TP.CloselyJuxtaposed Comma, Integer , Snd
    , Pair
  , (y)->{multiplier: TP.Range, args: y}


# The generic type where a specific identifier is required
Keyword = new TP.Ident((x)->new TP.Keyword(x.value, (x)->new LL.Keyword(x.value)))

# The type reference
TypeReference = new TP.CloselyJuxtaposed(
  OpeningAngle, new TP.CloselyJuxtaposed(
    Ident, ClosingAngle, Fst), (_,y)->TYPES[y.toLowerCase()] ? throw new UnknownType(y))

# This error is thrown when a user tries to reference a type that does not exist
class UnknownType extends Error
  constructor: (@type) ->
    @message = "unknown type <#{@type}>"


# The union of all component value types
ComponentValueType = pairsOf TP.ExclusiveOr, [
  Keyword
  TypeReference
  LiteralSlash
  LiteralComma
]

# We use this class to create recursive types. We define the type with the placeholder, and then replace it afterwards.
class PLACEHOLDER extends TP.Type
  parse: -> throw new Error "PLACEHOLDER not replaced"

# This is the `[]` grouping bracket pair
Bracket = new TP.ExclusiveOr \
  ComponentValueType,
  new TP.SimpleBlock SS.OpeningSquareToken, PLACEHOLDER

# The basis for multipliers is the bracket
Multipliable = Bracket

# Multipliers
Multiplier = pairsOf TP.ExclusiveOr, [Asterisk, Plus, QuestionMark, RepeatCount, Hashmark], pair: Id, cons: Id
Multiplied = new TP.Juxtaposition(
  Multipliable,
  new TP.Optional(Multiplier),
  (a,multdata) ->
    if multdata
      new multdata.multiplier((multdata.args ? [])..., a)
    else
      a
)

# The basis for annotations is an optionally multiplied value
Annotatable = Multiplied

# Annotations
Annotated = new TP.ExclusiveOr \
  new TP.Juxtaposition(Ident, new TP.Juxtaposition(Colon, new PLACEHOLDER, Pair), (name,[_,a])->
    new TP.Annotation(name, a)),
  Annotatable
Annotated.a.b.b = Annotated

# Combinators
Juxtaposition = new TP.OneOrMore Annotated, (l)-> pairsOf(
  TP.Juxtaposition, l,
  pair: (x,y)->new LL.Juxtaposition([x,y])
  cons: Cons
)

And = new TP.DelimitedBy DblAmpersand, Juxtaposition, (l)-> pairsOf(
  TP.And, l,
  pair: (x,y)->new LL.And([x,y])
  cons: Cons
)

# We pass a parameter to the TT.InclusiveOr constructor, the semantic function to be used with the nested Optional type.
InclusiveOr = new TP.DelimitedBy Column, And, (l)-> pairsOf(
  TP.InclusiveOr, l,
  pair: (x,y)->new LL.InclusiveOr([x ? new LL.EmptyValue, y ? new LL.EmptyValue])
  cons: (x,y)->y.unshift(x ? new LL.EmptyValue) ; y
)

ExclusiveOr = new TP.DelimitedBy Bar, InclusiveOr, (l)-> pairsOf(
  TP.ExclusiveOr, l,
  pair: Id,
  cons: Id
)

# This is the last combinator nonterminal
Combined = ExclusiveOr

# We create the recursive type for the bracket, so that it can contain any combined values
Bracket.b.a = Combined


# We wrap the root into an AnnotationRoot so that it can manage the annotations.
# This might not be the best solution. We also wrap it to Full, so it must
# consume all tokens from the stream
module.exports = new TP.Full(Combined, (x)->new TP.AnnotationRoot(x))

TYPES.ident = new TP.Ident((x)->new LL.Keyword(x.value))
TYPES.number = new TP.Number((x)->new LL.Number(x.value))
TYPES.integer = new TP.Integer((x)->new LL.Number(x.value))
TYPES.percentage = new TP.Percentage((x)->new LL.Percentage(x.value))
TYPES.string = new TP.String((x)->new LL.String(x.value))

module.exports[k] = v for k,v of {
  UnknownType
  TYPES
}
