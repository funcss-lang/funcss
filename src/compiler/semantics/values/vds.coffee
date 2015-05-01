# This file contains the transformation rules (defined in terms of a Types tree)
# that transforms a type definition token stream to a Types tree. The result will
# transform an actual value token stream to an LLL value
#
TP = require "./tp_nodes"
SS = require "../../syntax/ss_nodes"
VL = require "./vl_nodes"

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
Dollar       = new TP.DelimLike(new SS.DelimToken('$'))


# We use this class to create recursive types. We define the type with the placeholder, and then replace it afterwards.
PLACEHOLDER =
  parse: -> throw new Error "PLACEHOLDER not replaced"


# helper types
Ident = new TP.Ident
Number = new TP.Number
Integer = new TP.Integer
Percentage = new TP.Percentage
String = new TP.String

# This is a semantic function for  AnnotationRoot and Annotation, to add markings to the tree if the node
# has (sub-)annotations.
AddMarkings = (x,markings) ->
  if markings and not isEmptyObject(markings)
    new VL.Marking(x, markings)
  else
    x

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
LiteralSlash = new TP.DelimLike(new SS.DelimToken('/'), (x)->new TP.DelimLike(x, (x)->new VL.Keyword("/")))
LiteralComma = new TP.DelimLike(new SS.CommaToken, (x)->new TP.DelimLike(x, (x)->new VL.Keyword(",")))

# Multiplier tokens with metadata for easy handling
Hashmark     = new TP.DelimLike(new SS.DelimToken('#'), ->{collection: VL.CommaDelimitedCollection, multiplier: TP.DelimitedByComma})
Plus         = new TP.DelimLike(new SS.DelimToken('+'), ->{collection: VL.Collection, multiplier: TP.OneOrMore})
QuestionMark = new TP.DelimLike(new SS.DelimToken('?'), ->{collection: no,  multiplier: TP.Optional})
Asterisk     = new TP.DelimLike(new SS.DelimToken('*'), ->{collection: VL.Collection, multiplier: TP.ZeroOrMore})

# The {A,B} syntax for repetition count.
# TODO {A,} and {A} syntax is also needed
RepeatCount =
  new TP.SimpleBlock SS.OpeningCurlyToken,
    new TP.CloselyJuxtaposed Integer,
      new TP.CloselyJuxtaposed Comma, Integer , Snd
    , Pair
  , ([from,to])->{collection: VL.Collection, multiplier: TP.Range, args: [from,to]}


# The generic type where a specific identifier is required
Keyword = new TP.Ident((x)->new TP.Keyword(x.value, (x)->new VL.Keyword(x.value)))

# The type reference
TypeReference = new TP.Juxtaposition(
  OpeningAngle, new TP.Juxtaposition(
    Ident, ClosingAngle, Fst), (_,y)->new TP.TypeReference(y))

# The function definition
FunctionalNotation = new TP.AnyFunctionalNotation(
  PLACEHOLDER,
  (name,x)->new TP.FunctionalNotation(name,x,(y)->new VL.FunctionalNotation(name, y)))

#### Annotations
#
#
# 
Variable = new TP.ExclusiveOr \
  new TP.CloselyJuxtaposed(Dollar, Ident, (x,y)->x+y),
  Ident
Variable.expected = "variable"
Annotation = new TP.Juxtaposition(
  Variable,
  new TP.Juxtaposition(
    Colon,
    new TP.ExclusiveOr(
      new TP.Ident((x)->new TP.TypeReference(x.value)),
      PLACEHOLDER # Bracket
    ),
    Snd
  ),
  (name,a)->new TP.Annotation(name, a, AddMarkings)
)

# The union of all component value types
ComponentValue = pairsOf TP.ExclusiveOr, [
  TypeReference
  Annotation
  Keyword
  FunctionalNotation
  LiteralSlash
  LiteralComma
]


#### Square brackets
# This is the `[]` grouping bracket pair
Bracketable = ComponentValue
Bracket = new TP.SimpleBlock SS.OpeningSquareToken, PLACEHOLDER
Bracketed = new TP.ExclusiveOr \
  Bracketable,
  Bracket


Annotation.b.b.b = Bracket




#### Multipliers
#

# The basis for multipliers is the bracket
Multipliable = Bracketed

# Multipliers
Multiplier = pairsOf TP.ExclusiveOr, [Asterisk, Plus, QuestionMark, RepeatCount, Hashmark], pair: Id, cons: Id
Multiplied = new TP.Juxtaposition(
  Multipliable,
  new TP.Optional(Multiplier),
  (a,multdata) ->
    if multdata
      if multdata.collection
        # Here we add an AnnotationRoot to the inside of the multiplier. This is necessary to
        # make it possible to write types like
        #
        #     x:[n:<number>|p:<percentage>]*
        #
        # Each element of the collection will be an object with fields from the internal annotations
        # if any annotation is present inside.
        new multdata.multiplier((multdata.args ? [])..., new TP.AnnotationRoot(a, AddMarkings), (arr)->new multdata.collection(arr))
      else
        new multdata.multiplier((multdata.args ? [])..., new TP.AnnotationRoot(a, AddMarkings), (x)->x ? new VL.EmptyValue)
    else
      a
)

# The basis for annotations is an optionally multiplied value
#Annotatable = Multiplied

# A helper function to decide if `x` is `{}` or not
isEmptyObject = (x) ->
  for k of x
    if x.hasOwnProperty(k)
      return false
  return true




# Annotations
#Annotated = new TP.ExclusiveOr \
#  new TP.Juxtaposition(Ident, new TP.Juxtaposition(Colon, PLACEHOLDER, Pair), (name,[_,a])->
#    new TP.Annotation name, a, AddMarkings),
#  Annotatable
#Annotated.a.b.b = Annotated

# Combinators
Juxtaposition = new TP.OneOrMore Multiplied, (l)-> pairsOf(
  TP.Juxtaposition, l,
  pair: (x,y)->new VL.Juxtaposition([x,y])
  cons: Cons
)

And = new TP.DelimitedBy DblAmpersand, Juxtaposition, (l)-> pairsOf(
  TP.And, l,
  pair: (x,y)->new VL.And([x,y])
  cons: Cons
)

# We pass a parameter to the TT.InclusiveOr constructor, the semantic function to be used with the nested Optional type.
InclusiveOr = new TP.DelimitedBy Column, And, (l)-> pairsOf(
  TP.InclusiveOr, l,
  pair: (x,y)->new VL.InclusiveOr([x ? new VL.EmptyValue, y ? new VL.EmptyValue])
  cons: (x,y)->y.unshift(x ? new VL.EmptyValue) ; y
)

ExclusiveOr = new TP.DelimitedBy Bar, InclusiveOr, (l)-> pairsOf(
  TP.ExclusiveOr, l,
  pair: Id,
  cons: Id
)

# This is the last combinator nonterminal
Combined = ExclusiveOr

# We create the recursive type for the bracket, so that it can contain any combined values
Bracket.a = Combined

# We create the recursive type for function as well
FunctionalNotation.a = Combined


# We wrap the root into an AnnotationRoot so that it can manage the annotations.
# This might not be the best solution. We also wrap it into Full, so it must
# consume all tokens from the stream
module.exports = new TP.Full(Combined, (x)->new TP.AnnotationRoot(x, AddMarkings))

TYPES.ident = new TP.Ident((x)->new VL.Keyword(x.value))
TYPES.number = new TP.Number((x)->new VL.Number(x.value))
TYPES.integer = new TP.Integer((x)->new VL.Number(x.value))
TYPES.percentage = new TP.Percentage((x)->new VL.Percentage(x.value))
TYPES.string = new TP.String((x)->new VL.String(x.value))

# This is used in syntactic contexts where a single type atom is allowed and
# brackets are required when the user needs more complex types.
Atom = Bracketed

module.exports[k] = v for k,v of {
  TYPES
  Atom
  TypeReference
}
