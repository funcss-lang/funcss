CS = require "./cascade/cs_nodes"

exports.SemanticGraph = class SemanticGraph
  constructor: () ->
    @simpleRules = []
    @propertyValueTypes = {}
    @types = {}


