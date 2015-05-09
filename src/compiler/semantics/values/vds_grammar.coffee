# This file contains the transformation rules (defined in terms of a Types tree)
# that transforms a type definition token stream to a Types tree. The result will
# transform an actual value token stream to an LLL value
#
GR = require "../../syntax/gr_nodes"
SS = require "../../syntax/ss_nodes"
VL = require "./vl_nodes"

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
OpeningAngle = new GR.DelimLike(new SS.DelimToken('<'))
ClosingAngle = new GR.DelimLike(new SS.DelimToken('>'))
OpeningCurly = new GR.DelimLike(new SS.OpeningCurlyToken)
ClosingCurly = new GR.DelimLike(new SS.ClosingCurlyToken)
OpeningSquare= new GR.DelimLike(new SS.OpeningSquareToken)
ClosingSquare= new GR.DelimLike(new SS.ClosingSquareToken)
Colon        = new GR.DelimLike(new SS.ColonToken)
Ampersand    = new GR.DelimLike(new SS.DelimToken('&'))
DblAmpersand = new GR.CloselyJuxtaposed(Ampersand, Ampersand, ->)
Column       = new GR.DelimLike(new SS.ColumnToken)
Bar          = new GR.DelimLike(new SS.DelimToken('|'))
Comma        = new GR.DelimLike(new SS.CommaToken)
Dollar       = new GR.DelimLike(new SS.DelimToken('$'))


# We use this class to create recursive types. We define the type with the placeholder, and then replace it afterwards.
PLACEHOLDER =
  parse: -> throw new Error "PLACEHOLDER not replaced"


# helper types
Ident = new GR.Ident
Number = new GR.Number
Integer = new GR.Integer
Percentage = new GR.Percentage
String = new GR.String

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
LiteralSlash = new GR.DelimLike(new SS.DelimToken('/'), (x)->new GR.DelimLike(x, (x)->new VL.Keyword("/")))
LiteralComma = new GR.DelimLike(new SS.CommaToken, (x)->new GR.DelimLike(x, (x)->new VL.Keyword(",")))

# Multiplier tokens with metadata for easy handling
Hashmark     = new GR.DelimLike(new SS.DelimToken('#'), ->{collection: VL.CommaDelimitedCollection, multiplier: GR.DelimitedByComma})
Plus         = new GR.DelimLike(new SS.DelimToken('+'), ->{collection: VL.Collection, multiplier: GR.OneOrMore})
QuestionMark = new GR.DelimLike(new SS.DelimToken('?'), ->{collection: no,  multiplier: GR.Optional})
Asterisk     = new GR.DelimLike(new SS.DelimToken('*'), ->{collection: VL.Collection, multiplier: GR.ZeroOrMore})

# The {A,B} syntax for repetition count.
# TODO {A,} and {A} syntax is also needed
RepeatCount =
  new GR.SimpleBlock SS.OpeningCurlyToken,
    new GR.CloselyJuxtaposed Integer,
      new GR.CloselyJuxtaposed Comma, Integer , Snd
    , Pair
  , ([from,to])->{collection: VL.Collection, multiplier: GR.Range, args: [from,to]}


# The generic type where a specific identifier is required
Keyword = new GR.Ident((x)->new GR.Keyword(x.value, (x)->new VL.Keyword(x.value)))

# The type reference
TypeReference = new GR.Juxtaposition(
  OpeningAngle, new GR.Juxtaposition(
    new GR.ExclusiveOr(new GR.Ident((x)->[x.value,no]), new GR.String((x)->[x.value,yes]))
    ClosingAngle,
    Fst
  ), (_,[name,quoted])->new GR.TypeReference(name,quoted))

# The function definition
FunctionalNotation = new GR.AnyFunctionalNotation(
  PLACEHOLDER,
  (name,x)->new GR.FunctionalNotation(name,x,(y)->new VL.FunctionalNotation(name, y)))

#### Annotations
#
#
# 
Variable = new GR.ExclusiveOr \
  new GR.CloselyJuxtaposed(Dollar, Ident, (x,y)->x+y),
  Ident
Variable.expected = "variable"
Annotation = new GR.Juxtaposition(
  Variable,
  new GR.Juxtaposition(
    Colon,
    new GR.ExclusiveOr(
      new GR.Ident((x)->new GR.TypeReference(x.value)),
      PLACEHOLDER # Bracket
    ),
    Snd
  ),
  (name,a)->new GR.Annotation(name, a, AddMarkings)
)

# The union of all component value types
ComponentValue = pairsOf GR.ExclusiveOr, [
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
Bracket = new GR.SimpleBlock SS.OpeningSquareToken, PLACEHOLDER
Bracketed = new GR.ExclusiveOr \
  Bracketable,
  Bracket


Annotation.b.b.b = Bracket




#### Multipliers
#

# The basis for multipliers is the bracket
Multipliable = Bracketed

# Multipliers
Multiplier = pairsOf GR.ExclusiveOr, [Asterisk, Plus, QuestionMark, RepeatCount, Hashmark], pair: Id, cons: Id
Multiplied = new GR.Juxtaposition(
  Multipliable,
  new GR.Optional(Multiplier),
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
        new multdata.multiplier((multdata.args ? [])..., new GR.AnnotationRoot(a, AddMarkings), (arr)->new multdata.collection(arr))
      else
        new multdata.multiplier((multdata.args ? [])..., new GR.AnnotationRoot(a, AddMarkings), (x)->x ? new VL.EmptyValue)
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
#Annotated = new GR.ExclusiveOr \
#  new GR.Juxtaposition(Ident, new GR.Juxtaposition(Colon, PLACEHOLDER, Pair), (name,[_,a])->
#    new GR.Annotation name, a, AddMarkings),
#  Annotatable
#Annotated.a.b.b = Annotated

# Combinators
Juxtaposition = new GR.OneOrMore Multiplied, (l)-> pairsOf(
  GR.Juxtaposition, l,
  pair: (x,y)->new VL.Juxtaposition([x,y])
  cons: Cons
)

And = new GR.DelimitedBy DblAmpersand, Juxtaposition, (l)-> pairsOf(
  GR.And, l,
  pair: (x,y)->new VL.And([x,y])
  cons: Cons
)

# We pass a parameter to the TT.InclusiveOr constructor, the semantic function to be used with the nested Optional type.
InclusiveOr = new GR.DelimitedBy Column, And, (l)-> pairsOf(
  GR.InclusiveOr, l,
  pair: (x,y)->new VL.InclusiveOr([x ? new VL.EmptyValue, y ? new VL.EmptyValue])
  cons: (x,y)->y.unshift(x ? new VL.EmptyValue) ; y
)

ExclusiveOr = new GR.DelimitedBy Bar, InclusiveOr, (l)-> pairsOf(
  GR.ExclusiveOr, l,
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
Root = new GR.Just(Combined, (x)-> new GR.AnnotationRoot(x, AddMarkings))

# This is an optional version of root. This is used e.g. for 
# functional notation arguments.
OptionalRoot = new GR.Optional(
  Root,
  (x)-> x ? new GR.Empty(->new VL.EmptyValue)
)

# We wrap the grammar into Full, so it must consume all tokens from the stream (except
# starting and ending whitespace)
# XXX is this needed?
Vds = new GR.Full(Root)



# This is used in syntactic contexts where a single type atom is allowed and
# brackets are required when the user needs more complex types.
Atom = Bracketed

module.exports = Vds
module.exports[k] = v for k,v of {
  Atom
  TypeReference
  OptionalRoot
}
