# The semantic analyser
#
# This unit is responsible for building a style graph from a style sheet.
# It provides a modular framework for compiler modules that can add new
# semantic functionality.
#

SS = require "./syntax/ss_nodes"
SG = require "./semantics/sg_nodes"
Cascade = require "./semantics/cascade"
Def = require "./semantics/def"

module.exports = Semantics = (ss) ->
  sg = new SG.SemanticGraph

  for rule in ss.value
    if rule instanceof SS.QualifiedRule
      Cascade.qualifiedRule(rule, sg)
    else if rule instanceof SS.AtRule
      Semantics.atRules[rule.name].handle(rule, sg)
    else
      throw new Error "Internal error in Semantics: Unknown rule type in SS.Stylesheet"

  sg
    
Semantics[k]=v for k,v of {
  atRules: {
    def: Def.def
  }
}


#exports.AtRule = class AtRule
#  constructor: (@preludeType, @blockType, @blockCategory, @blockRequired = false) ->
#    unless @blockCategory in [undefined, "list_of_component_values", "list_of_rules", "list_of_declarations"]
#      throw new Error "invalid block category: #{@blockCategory}"
#  handle: (atrule) ->
#    throw new Error if atrule.value is undefined and @blockRequired
#    throw new Error if atrule.value isnt undefined and !@blockCategory
#    new GR.Full(@preludeType).parse new Stream(atrule.prelude)
#    if atrule.value
#      new GR.Full(@blockType).parse new Stream(Parser["parse_#{@blockCategory}"]atrule.prelude)
#
    


  


