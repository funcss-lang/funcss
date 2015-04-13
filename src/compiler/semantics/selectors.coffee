TP = require "./values/tp_nodes"
SL = require "./selectors/sl_nodes"

TypeSelector = new TP.Ident((x)->new SL.TypeSelector(x.value))
Selector = TypeSelector

SelectorGroup = new TP.DelimitedByComma(Selector)

module.exports = SelectorGroup

