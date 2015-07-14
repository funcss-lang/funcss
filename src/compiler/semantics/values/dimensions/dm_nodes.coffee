assert = "../../../helpers/assert"
GR = require "../../../syntax/gr_nodes"
VL = require "../../values/vl_nodes"
DM = exports

class DM.Metric
  constructor: (@name, @canonicalUnitName, @units = {})->
    @units[@canonicalUnitName] = new VL.Number 1

  grammar: ()->
    metric = @
    g = new GR.Dimension(@name, (x) ->
      if x.value is 0
        # x might be a NumberToken in this case
        return new VL.Dimension(new VL.Number(0), metric.canonicalUnitName)
      multiplier = metric.units[x.unit] ? @stream.noMatchCurrent(metric.name)
      new VL.Dimension(new VL.Multiply(new VL.Number(x.value), multiplier), metric.canonicalUnitName)
    )
    g.decodejs = (x)=>"#{x}+#{JSON.stringify(@canonicalUnitName)}"
    g


