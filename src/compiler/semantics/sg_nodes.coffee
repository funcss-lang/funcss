## The Semantic Graph nodes
#
# These nodes represent the so-called Semantic Graph.
#
# *Outputs*
#
# - `ig()` returns the IG graph implementing the behavior of the tree
#
#

SS = require "../syntax/ss_nodes"
VdsGrammar = require "./values/vds_grammar"
IG         = require "../generator/ig_nodes"

SG = exports

class SG.SimpleRule
  constructor: (opts) ->
    {@mediaQuery, @selector, @name, @value, @important} = opts
  isConstantMediaQuery: -> false
  isConstantValue: -> false
  isConstantSelector: -> false
  selectorSpecificity: -> [0,0,0]


class SG.SemanticGraph
  constructor: () ->
    @simpleRules = []
    @propertyValueTypes = {}
    @types = VdsGrammar.TYPES
  getType: (name) ->
    @types[name]
  getQuotedType: (name) ->
    @propertyValueTypes[name]

  # One technique to implement custom values is to use a puppet stylesheet. We
  # insert a stylesheet with the apporopriate rules, and change the property
  # values in it. This cannot be used if the selector contains custom elements.
  
  puppetRules: ->
    @_puppetRules ?= for sr,index in @simpleRules
      pr = new SS.QualifiedRule(sr.selector)
      pr.index = index
      sr.puppetRule = pr
      pr

  puppetStylesheet: ->
    @_puppetStylesheet ?= new SS.Stylesheet @puppetRules()

  ig: () ->
    fb = new IG.FunctionBlock
    fb.push(pss = new IG.CssStylesheet @puppetStylesheet())
    for sr in @simpleRules
      fb.push new IG.Rule pss, sr.puppetRule.index
    for sr in @simpleRules
      fb.push new IG.DomReady new IG.Autorun new IG.SetDeclarationValue(sr.puppetRule.index, sr.name, sr.value)
    fb


