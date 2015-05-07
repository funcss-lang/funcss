# The custom functions/values/etc. module
#

Stream     = require "../../helpers/stream"
Parser     = require "../../syntax/parser"
SS         = require "../../syntax/ss_nodes"
GR         = require "../../syntax/gr_nodes"
Semantics  = require "../"
SG         = require "../sg_nodes"
Sel        = require "../selectors/sel_grammar"
CS         = require "../cascade/cs_nodes"
VdsGrammar = require "../values/vds_grammar"
DefGrammar = require "./def_grammar"

SG.SemanticGraph.prototype[k] = v for k,v of {
  insertDefinition: (def) ->
    value = @types[def.typeName].parse(def.rawValue)
    # TODO create the binding between the argument and the value somehow (when functions will be implemented)
    type = def.definable.makeType
    @types[def.typeName] = new GR.ExclusiveOr type, @types[def.typeName]
}


exports.def =
  handle: (atrule, sg) ->
    # TODO throw a different class
    throw new Error "block required for @def" if atrule.value is undefined
    # TODO create GR.Empty and use it instead of GR.Eof
    new GR.Full(new GR.Empty).parse new Stream(atrule.prelude)
    statements = Parser.parse_list_of_statements(atrule.value.value)
    for s in statements
      debugger
      def = new GR.Full(new GR.Optional(DefGrammar)).parse(new Stream(s))
      sg.insertDefinition def if def?







