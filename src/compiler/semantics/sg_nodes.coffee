CS = require "./cascade/cs_nodes"
VdsGrammar = require "./values/vds_grammar"

SG = exports
class SG.SemanticGraph
  constructor: () ->
    @simpleRules = []
    @propertyValueTypes = {}
    @types = VdsGrammar.TYPES
  getType: (name) ->
    @types[name]
  getQuotedType: (name) ->
    @propertyValueTypes[name]


