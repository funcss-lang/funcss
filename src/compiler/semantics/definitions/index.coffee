# The custom functions/values/etc. module
#

Stream     = require "../../helpers/stream"
Parser     = require "../../syntax/parser"
SS         = require "../../syntax/ss_nodes"
GR         = require "../../syntax/gr_nodes"
Semantics  = require "../"
Sel        = require "../selectors/sel_grammar"
VdsGrammar = require "../values/vds_grammar"
DefGrammar = require "./def_grammar"
IG         = require "../../generator/ig_nodes"


module.exports = class Definitions
  constructor: (@fs) ->
    @definitions
  consume_at_rule: (atrule) ->
    throw new ER.BlockRequired("@def") if atrule.value is undefined
    new GR.Full(new GR.Empty).parse new Stream(atrule.prelude, '{')
    statements = Parser.parse_list_of_statements(atrule.value.value)
    for s in statements
      debugger
      def = new GR.Full(new GR.Optional(DefGrammar)).parse(new Stream(s))
      if def?
        @consume_definition(def)

  consume_definition: (def) ->
    # TODO Do type inference
    throw new ER.TypeInferenceNotImplemented(def.definable) unless def.type?

    # We insert the new type into the table.
    @fs.types[def.type] = new GR.ExclusiveOr(
      def.grammar(@)
      @fs.types[def.type]
    )

  ig: ->
    new IG.Empty
    








