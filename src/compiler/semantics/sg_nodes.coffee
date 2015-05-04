CS = require "./cascade/cs_nodes"
Vds = require "./values/vds"

exports.SemanticGraph = class SemanticGraph
  constructor: () ->
    @simpleRules = []
    @propertyValueTypes = {}
    @types = Vds.TYPES
  getType: (name) ->
    @types[name]
  getQuotedType: (name) ->
    @propertyValueTypes[name]


