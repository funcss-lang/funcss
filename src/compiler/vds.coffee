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
Colon = new TP.DelimLike(new SS.ColonToken)

# simple types
Ident = new TP.Ident
Number = new TP.Number
Integer = new TP.Integer
Percentage = new TP.Percentage
String = new TP.String
Slash = new TP.DelimLike(new SS.DelimToken('/'), (x)->new TP.DelimLike(x))
Comma = new TP.DelimLike(new SS.CommaToken, (x)->new TP.DelimLike(x))

# The generic type where a specific identifier is required
IdentType = new TP.Ident((x)->new TP.IdentType(x.value))

# The type reference
TypeReference = new TP.Juxtaposition(
  OpeningAngle, new TP.Juxtaposition(
    Ident, ClosingAngle, Fst), (_,y)->TYPES[y.toLowerCase()] ? throw new UnknownType(y))

# This error is thrown when a user tries to reference a type that does not exist
class UnknownType extends Error
  constructor: (@type) ->
    @message = "unknown type <#{@type}>"


# The union of all component value types
ComponentValueType = PairsOf TP.Bar, [
  IdentType
  TypeReference
  Slash
  Comma
]

class PLACEHOLDER extends TP.Type
  parse: -> throw new Error "PLACEHOLDER not replaced"


# Annotations
AnnotatedValueType = new TP.Bar \
  new TP.Juxtaposition(Ident, new TP.Juxtaposition(Colon, new PLACEHOLDER, Pair), (name,[_,a])->
    new TP.Annotation(name, a)),
  ComponentValueType
AnnotatedValueType.a.b.b = AnnotatedValueType

# Juxtaposition
Juxtaposition = new TP.Plus(AnnotatedValueType, (l)->PairsOf(TP.Juxtaposition, l, Pair, Cons))


module.exports = new TP.Full(Juxtaposition, (x)->new TP.AnnotationRoot(x))

TYPES.ident = Ident
TYPES.number = Number
TYPES.integer = Integer
TYPES.percentage = Percentage
TYPES.string = String

module.exports[k] = v for k,v of {
  UnknownType
  TYPES
}
