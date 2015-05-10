# The custom functions/values/etc. module
#

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
    @definitions

  consume_at_rule: (atrule) ->
    throw new ER.BlockRequired("@def") if atrule.value is undefined
    new GR.Empty().parse(atrule.prelude, '{')
    statements = Parser.parse_list_of_statements(atrule.value.value)
    for s in statements
      def = new GR.Optional(DefGrammar).parse(s.value)
      if def?
        @consume_definition(def)

    return

  consume_definition: (def) ->
    # TODO Do type inference
    throw new ER.TypeInferenceNotImplemented(def.definable) unless def.type?

    # We insert the new type into the table.
    @fs.setType(def.type, def.grammar(@fs))

    return

  ig: ->
    new IG.Empty
    








