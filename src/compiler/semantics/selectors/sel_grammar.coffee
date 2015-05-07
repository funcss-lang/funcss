GR = require "../../syntax/gr_nodes"
SL = require "./sl_nodes"

TypeSelector = new GR.Ident((x)->new SL.TypeSelector(x.value))
Selector = TypeSelector

SelectorGroup = new GR.DelimitedByComma(Selector)

module.exports = SelectorGroup

