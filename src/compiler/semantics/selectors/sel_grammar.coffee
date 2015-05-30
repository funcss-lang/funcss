GR = require "../../syntax/gr_nodes"
SL = require "./sl_nodes"
SS = require "../../syntax/ss_nodes"

Colon        = new GR.DelimLike(new SS.ColonToken)
Dot          = new GR.DelimLike(new SS.DelimToken('.'))
Snd = (_,y) -> y

# We use this class to create recursive grammars. We define the grammar with the placeholder, and then replace it afterwards.
PLACEHOLDER =
  parse: -> throw new Error "PLACEHOLDER not replaced"


TypeSelector = new GR.Ident((x)->new SL.TypeSelector(x.value))

ClassSelector = new GR.CloselyJuxtaposed(
  Dot,
  new GR.Ident((x)->new SL.ClassSelector(x.value)),
  Snd
)

SimpleSelector = new GR.ExclusiveOr(
  TypeSelector,
  ClassSelector
)

Combinable = SimpleSelector
ChildCombinator = new GR.DelimLike(new SS.DelimToken('>'), ->SL.ChildCombinator)
Combinator = new GR.Optional(
  ChildCombinator,
  (x)->x ? SL.DescendantCombinator
)
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

Pseudoelementable = Combined
Pseudoelemented = new GR.CloselyJuxtaposed(
  Pseudoelementable,
  new GR.Optional(
    new GR.CloselyJuxtaposed(
      Colon,
      new GR.CloselyJuxtaposed(
        Colon,
        new GR.Ident((x)->x.value),
        Snd
      ),
      Snd
    )
  ),
  (x,y)-> if y then new SL.Pseudoelement(y,x) else x
)


Selector = Pseudoelemented

SelectorGroup = new GR.DelimitedByComma(Selector)

module.exports = SelectorGroup

