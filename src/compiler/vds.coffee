TP = require "../../src/compiler/types"
SS = require "../../src/compiler/stylesheet"

TYPES = {}

# Helper functions
Id = Fst = (x) -> x
Snd = (_,y) -> y
Pair = (x,y) -> [x,y]
Cons = (x,y) -> y.unshift x; y

# Makes a chain of binary combinator types.
#
# `t` is the constructor of the binary type
#
# `pair` and `cons` are the semantic functions used for the first two
# and the following constructor invocations respectively.
PairsOf = (t, list, pair=undefined, cons=undefined) ->
  if !list.length
    throw new Error "internal error in VDS: cannot make pairs of empty list or a non-list"
  if list.length is 1
    return list[0]
  if list.length is 2
    return new t(list[0], list[1], pair)
  return new t(list[0], PairsOf(t, list[1..-1], pair, cons), cons)

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


# simple types
Ident = new TP.Ident
Number = new TP.Number
Integer = new TP.Integer
Percentage = new TP.Percentage
String = new TP.String
LiteralSlash = new TP.DelimLike(new SS.DelimToken('/'), (x)->new TP.DelimLike(x))
LiteralComma = new TP.DelimLike(new SS.CommaToken, (x)->new TP.DelimLike(x))

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
Keyword = new TP.Ident((x)->new TP.Keyword(x.value))

# The type reference
TypeReference = new TP.CloselyJuxtaposed(
  OpeningAngle, new TP.CloselyJuxtaposed(
    Ident, ClosingAngle, Fst), (_,y)->TYPES[y.toLowerCase()] ? throw new UnknownType(y))

# This error is thrown when a user tries to reference a type that does not exist
class UnknownType extends Error
  constructor: (@type) ->
    @message = "unknown type <#{@type}>"


# The union of all component value types
ComponentValueType = PairsOf TP.ExclusiveOr, [
  Keyword
  TypeReference
  LiteralSlash
  LiteralComma
]

# We use this class to create recursive types. We define the type with the placeholder, and then replace it afterwards.
class PLACEHOLDER extends TP.Type
  parse: -> throw new Error "PLACEHOLDER not replaced"

#Brackets = new TP.ExclusiveOr \
  #TP.Juxtaposition OpeningSquareToken, PLACEHOLDER, ClosingAngle

Multipliable = ComponentValueType

# Multipliers
Multiplier = PairsOf TP.ExclusiveOr, [Asterisk, Plus, QuestionMark, RepeatCount, Hashmark], Id, Id
Multiplied = new TP.Juxtaposition(
  Multipliable,
  new TP.Optional(Multiplier),
  (a,multdata) ->
    if multdata
      new multdata.multiplier((multdata.args ? [])..., a)
    else
      a
)

# Annotations
Annotated = new TP.ExclusiveOr \
  new TP.Juxtaposition(Ident, new TP.Juxtaposition(Colon, new PLACEHOLDER, Pair), (name,[_,a])->
    new TP.Annotation(name, a)),
  Multiplied
Annotated.a.b.b = Annotated

# Combinators
Juxtaposition = new TP.OneOrMore(Annotated,               (l)->PairsOf(TP.Juxtaposition, l, Pair, Cons))
Both        = new TP.DelimitedBy(DblAmpersand, Juxtaposition, (l)->PairsOf(TP.Both,          l, Pair, Cons))
InclusiveOr = new TP.DelimitedBy(Column,       Both,          (l)->PairsOf(TP.InclusiveOr,   l, Pair, Cons))
ExclusiveOr = new TP.DelimitedBy(Bar,          InclusiveOr,   (l)->PairsOf(TP.ExclusiveOr,   l, Id, Id))
Combined = ExclusiveOr


#module.exports = new TP.Full(Juxtaposition, (x)->new TP.AnnotationRoot(x))
module.exports = new TP.Full(Combined, (x)->new TP.AnnotationRoot(x))

TYPES.ident = Ident
TYPES.number = Number
TYPES.integer = Integer
TYPES.percentage = Percentage
TYPES.string = String

module.exports[k] = v for k,v of {
  UnknownType
  TYPES
}
