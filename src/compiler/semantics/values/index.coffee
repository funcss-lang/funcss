
GR = require "../../syntax/gr_nodes"
VL = require "./vl_nodes"

exports.primitiveTypes =
  ident:      new GR.Ident((x)->new VL.Keyword(x.value))
  number:     new GR.Number((x)->new VL.Number(x.value))
  integer:    new GR.Integer((x)->new VL.Number(x.value))
  percentage: new GR.Percentage((x)->new VL.Percentage(x.value))
  string:     new GR.String((x)->new VL.String(x.value))


exports.dimensions =
  length:
    px: "TODO"



