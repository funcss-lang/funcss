# The custom functions/values/etc. module
#

Semantics = require "../semantics"
Selectors = require "./selectors"
Stream = require "../helpers/stream"
TP = require "./values/tp_nodes"
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
    @types[def.typeName] = new TP.ExclusiveOr type, @types[def.typeName]
}


exports.def =
  handle: (atrule, sg) ->
    # TODO throw a different class
    throw new Error "block required for @def" if atrule.value is undefined
    # TODO create TP.Empty and use it instead of TP.Eof
    new TP.Full(new TP.Empty).parse new Stream(atrule.prelude)
    statements = Parser.parse_list_of_statements(atrule.value.value)
    for s in statements
      debugger
      def = new TP.Full(new TP.Optional(DefGrammar)).parse(new Stream(s))
      sg.insertDefinition def if def?







