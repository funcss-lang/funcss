# The custom functions/values/etc. module
#

Semantics = require "../semantics"
Selectors = require "./selectors"
Stream = require "../helpers/stream"
GR = require "./../syntax/gr_nodes"
CS = require "./cascade/cs_nodes"
Parser = require "../syntax/parser"
Vds = require "./values/vds"
SS = require "../syntax/ss_nodes"
SG = require "./sg_nodes"
DefGrammar = require "./def/def_grammar"
debugger

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







