CS = require "./cascade/cs_nodes"
VdsGrammar = require "./values/vds_grammar"

exports.SemanticGraph = class SemanticGraph
  constructor: () ->
    @simpleRules = []
    @propertyValueTypes = {}
    @types = VdsGrammar.TYPES
  getType: (name) ->
    @types[name]
  getQuotedType: (name) ->
    @propertyValueTypes[name]


