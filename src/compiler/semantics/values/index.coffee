
GR = require "../../syntax/gr_nodes"
VL = require "./vl_nodes"

exports.primitiveTypes =
  ident:      new GR.Ident((x)->new VL.Keyword(x.value))
  number:     new GR.Number((x)->new VL.Number(x.value))
  integer:    new GR.Integer((x)->new VL.Number(x.value))
  percentage: new GR.Percentage((x)->new VL.Percentage(x.value))
  string:     new GR.String((x)->new VL.String(x.value))

# decodejs(x) functions
#
# This returns a JS code which, when evaled, returns the CSS representation of the value

exports.primitiveTypes.ident.decodejs = (x) -> x
exports.primitiveTypes.number.decodejs = (x) -> x
exports.primitiveTypes.integer.decodejs = (x) -> "Math.round(#{x})"
exports.primitiveTypes.percentage.decodejs = (x) -> "#{x}*100 + '%'"
exports.primitiveTypes.string.decodejs = (x) -> "JSON.stringify(#{x})" # TODO add own unescaping function

exports.dimensions =
  length:
    px: "TODO"



