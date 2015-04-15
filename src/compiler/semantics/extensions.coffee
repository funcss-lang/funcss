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

Snd = (_,y) ->y

Definition = new TP.Juxtaposition(
  Vds.Atom,
  new TP.Juxtaposition(
    new TP.DelimLike(new SS.ColonToken),
    Vds.TypeReference,
    Snd
  ),
  (x,y) -> [x,y]
)

exports.def = (atrule, sg) ->
  [subtype, typeRef] = new TP.Full(Definition).parse new Stream atrule.prelude






