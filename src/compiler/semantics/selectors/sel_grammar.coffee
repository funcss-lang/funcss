GR = require "../../syntax/gr_nodes"
SL = require "./sl_nodes"

TypeSelector = new GR.Ident((x)->new SL.TypeSelector(x.value))


# We use this class to create recursive grammars. We define the grammar with the placeholder, and then replace it afterwards.
PLACEHOLDER =
  parse: -> throw new Error "PLACEHOLDER not replaced"

Combinable = TypeSelector
DescendantCombinator = new GR.Empty(->SL.DescendantCombinator)
Combinator = DescendantCombinator
Combined = new GR.Juxtaposition(
  Combinable,
  new GR.Optional(
    new GR.Juxtaposition(
      Combinator,
      PLACEHOLDER,
      (comb,tail)->[comb,tail]
    )
  ),
  (head,comb_tail)->
    if comb_tail?
      [comb,tail] = comb_tail
      new comb(head,tail)
    else
      head
)
Combined.b.a.b = Combined


Selector = Combined

SelectorGroup = new GR.DelimitedByComma(Selector)

module.exports = SelectorGroup

