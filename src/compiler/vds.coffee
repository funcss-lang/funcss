TP = require "../../src/compiler/types"
SS = require "../../src/compiler/stylesheet"

TYPES = {}

# Helper functions
Id = Fst = (x) -> x
Snd = (_,y) -> y

# Simple types
OpeningAngle = new TP.DelimLike(new SS.DelimToken('<'))
ClosingAngle = new TP.DelimLike(new SS.DelimToken('>'))
Ident = new TP.Ident

# The generic type where a specific identifier is required
IdentType = new TP.Ident((x)->new TP.IdentType(x.value))

# The type reference
TypeReference = new TP.Juxtaposition(
  OpeningAngle, new TP.Juxtaposition(
    Ident, ClosingAngle, Fst), (_,y)->TYPES[y.toLowerCase()] ? throw new UnknownType(y))

# This error is thrown when a user tries to reference a type that does not exist
class UnknownType extends Error
  constructor: (@type) ->
    @message = "unknown type <#{@type}>"


# The union of all component value types
ComponentValueType = new TP.Bar(IdentType, TypeReference)


module.exports = ComponentValueType

TYPES.ident = Ident

module.exports[k] = v for k,v of {
  UnknownType
  TYPES
}
