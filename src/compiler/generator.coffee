
IG = require "./generator/ig_nodes"
SG = require "./semantics/sg_nodes"
SS = require "./syntax/ss_nodes"

SG.SemanticGraph.prototype[k] = v for k,v of {

  puppetRules: ->
    @_puppetRules ?= for sr,index in @simpleRules
      pr = new SS.QualifiedRule(sr.selector)
      pr.index = index
      sr.puppetRule = pr
      pr

  puppetStylesheet: ->
    @_puppetStylesheet ?= new SS.Stylesheet @puppetRules()

  js: ->
    js = new IG.FunctionBlock
    js.push(pss = new IG.CssStylesheet @puppetStylesheet())
    for sr in @simpleRules
      js.push new IG.Rule pss, sr.puppetRule.index
    for sr in @simpleRules
      js.push new IG.DomReady new IG.Autorun new IG.SetDeclarationValue(sr.puppetRule.index, sr.name, sr.value)
    js

}


module.exports = (sg) ->
  if not (sg instanceof SG.SemanticGraph)
    throw new Error "Generator should be called with a SemanticGraph"
  sg.js()


