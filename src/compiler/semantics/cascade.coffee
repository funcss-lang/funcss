# The qualified rules (normal CSS rules) module
#

Semantics = require "../semantics"
Selectors = require "./selectors"
Stream = require "../helpers/stream"
GR = require "./../syntax/gr_nodes"
CS = require "./cascade/cs_nodes"
Parser = require "../syntax/parser"
VdsGrammar = require "./values/vds_grammar"


exports.qualifiedRule = (qrule, sg) ->
  sel = Selectors.parse new Stream qrule.prelude
  for decl in Parser.parse_list_of_declarations qrule.value.value
    # TODO remove mock
    type = sg.propertyValueTypes[decl.name] || new GR.Full(VdsGrammar.parse(new Stream(Parser.parse_list_of_component_values("<ident>"))))
    # TODO remove this
    type.setSg(sg)
    if not type
      throw new Error "Undefined property: #{decl.name}"
    sg.simpleRules.push new CS.SimpleRule
      mediaQuery: null
      selector: sel
      name: decl.name
      value: type.parse(new Stream decl.value)
      important: decl.important


