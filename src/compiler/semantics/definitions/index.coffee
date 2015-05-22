# The custom functions/values/etc. module
#

ER         = require "../../errors/er_nodes"
Parser     = require "../../syntax/parser"
SS         = require "../../syntax/ss_nodes"
GR         = require "../../syntax/gr_nodes"
Semantics  = require "../"
Sel        = require "../selectors/sel_grammar"
VdsGrammar = require "../values/vds_grammar"
DefGrammar = require "./def_grammar"
IG         = require "../../generator/ig_nodes"
require "../../syntax/statements"


module.exports = class Definitions
  constructor: (@fs) ->

  consume_at_rule: (atrule) ->
    throw new ER.BlockRequired("@def") if atrule.value is undefined
    new GR.Empty().parse(atrule.prelude, '{')
    statements = Parser.parse_list_of_statements(atrule.value.value)
    for s in statements
      def = DefGrammar.parseStatement(s)
      if def?
        @consume_definition(def)

    return

  consume_definition: (def) ->
    # TODO Do type inference
    throw new ER.TypeInferenceNotImplemented(def.definable) unless def.typeName?

    newType = def.grammar(@fs)

    # We insert the new type into the table.
    @fs.setType(def.typeName, newType)


    return

  ig: ->
    new IG.Empty
    








