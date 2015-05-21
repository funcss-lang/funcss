
GR = require "../../syntax/gr_nodes"
VL = require "./vl_nodes"

exports.primitiveTypes =
  ident:      new GR.Ident((x)->new VL.Keyword(x.value))
  number:     new GR.Number((x)->new VL.Number(x.value))
  integer:    new GR.Integer((x)->new VL.Number(x.value))
  percentage: new GR.Percentage((x)->new VL.Percentage(x.value))
  string:     new GR.String((x)->new VL.String(x.value))

  color:      new GR.Hash((x)->
    v = x.value
    if /^[0-9a-fA-F]{3,6}$/.exec v
      if v.length is 3
        new VL.Color
          r: new VL.Number Number.parseInt v.charAt(0), 16
          g: new VL.Number Number.parseInt v.charAt(1), 16
          b: new VL.Number Number.parseInt v.charAt(2), 16
      else if v.length is 6
        new VL.Color
          r: new VL.Number Number.parseInt v.substr(0,2), 16
          g: new VL.Number Number.parseInt v.substr(2,2), 16
          b: new VL.Number Number.parseInt v.substr(4,2), 16
      else
        throw new Error "Internal error in FuncSS"
    else
      throw new ER.InvalidColor "#"+v
  )

# decodejs(x) functions
#
# This returns a JS code which, when evaled, returns the CSS representation of the value

exports.primitiveTypes.ident.decodejs = (x) -> x
exports.primitiveTypes.number.decodejs = (x) -> x
exports.primitiveTypes.integer.decodejs = (x) -> "Math.round(#{x})"
exports.primitiveTypes.percentage.decodejs = (x) -> "#{x}*100 + '%'"
exports.primitiveTypes.string.decodejs = (x) -> "JSON.stringify(#{x})" # TODO add own unescaping function
exports.primitiveTypes.color.decodejs = (x) ->
  "(function(){var c=#{x}; return 'rgb('+c.r+','+c.g+','+c.b+')'})()"

exports.dimensions =
  length:
    px: "TODO"



