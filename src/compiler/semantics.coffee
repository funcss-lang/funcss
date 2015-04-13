# The semantic analyser
#
# This unit is responsible for building a style graph from a style sheet.
# It provides a modular framework for compiler modules that can add new
# semantic functionality.
#

SS = require "./syntax/ss_nodes"
SG = require "./semantics/sg_nodes"
Cascade = require "./semantics/cascade"

module.exports = Semantics = (ss) ->
  sg = new SG.SemanticGraph

  for rule in ss.value
    if rule instanceof SS.QualifiedRule
      Cascade.qualifiedRule(rule, sg)
    else if rule instanceof SS.AtRule
      Semantics.atRule(rule, sg)
    else
      throw new Error "Internal error in Semantics: Unknown rule type in SS.Stylesheet"

  sg
    
Semantics[k]=v for k,v of {
  _handleQualifiedRule: null
  _handleAtRule: {}
  _handleStart: []

  qualifiedRule: (rule, sg) ->
    @_handleQualifiedRule(rule, sg)
  atRule: (rule, sg) ->
    handle = @_handleAtRule[rule.name]
    handle(rule, sg)
  start: (sg) ->
    handle(sg) for handle in @_handleStart
}




  


