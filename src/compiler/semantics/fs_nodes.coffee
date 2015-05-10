## The Functional Stylesheet nodes
#
# These nodes represent the semantic representation of a Functional Stylesheet.
# A Functional Stylesheet contains all interpreted declarations from builtins
# and the lib.
#
# *Outputs*
#
# - `ig()` returns the IG graph implementing the behavior of the functional stylesheet
#
#

ER         = require "../errors/er_nodes"
Parser     = require "../syntax/parser"
SS         = require "../syntax/ss_nodes"
GR         = require "../syntax/gr_nodes"
VdsGrammar = require "./values/vds_grammar"
Values     = require "./values"
IG         = require "../generator/ig_nodes"
Definitions= require "./definitions"
Cascade    = require "./cascade"
SelGrammar = require "./selectors/sel_grammar"


FS = exports

vds = (str) ->
  VdsGrammar.parse(str)

class FS.FunctionalStylesheet
  constructor: (ss) ->
    @definitions = new Definitions(@)
    @cascade = new Cascade(@)
    @atRuleHandlers = {
      def: @definitions
    }
    @_propertyTypes = {
      'background-color': vds("<ident>")
      'background': vds("<ident>")
      'opacity': vds("<number>")
    }
    @_typeStack = [
      Values.primitiveTypes,
      {}
    ]
    @_dimensionStack = [
      Values.dimensions,
      {}
    ]

    @consume_stylesheet(ss) if ss?

  getPropertyType: (name, require=true) ->
    if (type = @_propertyTypes[name])?
      return type
    throw new ER.UnknownProperty(name) if require

  setPropertyType: (name, newType) ->
    oldType = @getPropertyType(name, false)
    @_propertyTypes[name] =
      if oldType?
        new GR.ExclusiveOr(oldType, newType)
      else
        newType

  getType: (name, require=true) ->
    for i in [@_typeStack.length-1..0]
      if (type = @_typeStack[i][name])?
        return type
    throw new ER.UnknownType(name) if require

  setType: (name, newType) ->
    oldType = @getType(name, false)
    @_typeStack[@_typeStack.length-1][name] =
      if oldType?
        new GR.ExclusiveOr(oldType, newType)
      else
        newType

    

  push_scope: () ->
    @_typeStack.push {}
    @_dimensionStack.push {}

  pop_scope: () ->
    @_typeStack.pop {}
    @_dimensionStack.pop {}

  consume_stylesheet: (ss) ->
    for rule in ss.value
      if rule instanceof SS.QualifiedRule
        @consume_qualified_rule(rule)
      else if rule instanceof SS.AtRule
        @consume_at_rule(rule)
      else
        throw new Error "Internal error in FunCSS: Unknown rule type in SS.Stylesheet"

  consume_at_rule: (rule) ->
    handler = @atRuleHandlers[rule.name]
    throw new ER.UnknownAtRule(rule.name) unless handler?
    handler.consume_at_rule(rule)

    
  consume_qualified_rule: (qrule) ->
    sel = SelGrammar.parse(qrule.prelude)
    for decl in Parser.parse_list_of_declarations qrule.value.value
      @cascade.consume_declaration(sel, decl)

  ig: ->
    ig = new IG.FunctionBlock
    ig.push @definitions.ig()
    ig.push @cascade.ig()
    ig






class FS.SimpleRule
  constructor: (opts) ->
    {@mediaQuery, @selector, @name, @value, @important} = opts
  isConstantMediaQuery: -> false
  isConstantValue: -> false
  isConstantSelector: -> false
  selectorSpecificity: -> [0,0,0]




