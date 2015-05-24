GR = require "../../../syntax/gr_nodes"
VL = require "../../values/vl_nodes"
DM = exports

class DM.Metric
  constructor: (@name, @canonicalUnitName, @units = {})->
    @units[@canonicalUnitName] = new VL.Number 1

  grammar: ()->
    metric = @
    g = new GR.Dimension(@name, (x) ->
      multiplier = metric.units[x.unit] ? @stream.noMatchCurrent(metric.name)
      new VL.Dimension(new VL.Multiply(new VL.Number(x.value), multiplier), metric.canonicalUnitName)
    )
    g.decodejs = (x)->"#{x}#{@canonicalUnitName}"
    g


