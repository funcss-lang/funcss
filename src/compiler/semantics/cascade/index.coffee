Stream     = require "../../helpers/stream"
SS         = require "../../syntax/ss_nodes"
GR         = require "../../syntax/gr_nodes"
FS         = require "../fs_nodes"
IG         = require "../../generator/ig_nodes"


module.exports = class Cascade
  constructor: (@fs) ->
    @simpleRules = []

  consume_declaration: (sel, decl) ->
    type = new GR.Full(@fs.getPropertyType(decl.name))
    type.setFs(@fs)

    @simpleRules.push new FS.SimpleRule
      mediaQuery: null
      selector: sel
      name: decl.name
      value: type.parse(new Stream decl.value)
      important: decl.important

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
    ig = new IG.Sequence
    ig.push(pss = new IG.CssStylesheet @puppetStylesheet())
    for sr in @simpleRules
      ig.push new IG.Rule pss, sr.puppetRule.index
    for sr in @simpleRules
      ig.push new IG.DomReady new IG.Autorun new IG.SetDeclarationValue(sr.puppetRule.index, sr.name, sr.value)
    ig

