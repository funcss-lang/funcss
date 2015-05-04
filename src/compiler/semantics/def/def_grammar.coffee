TP = require "../values/tp_nodes"
Parser = require "../../syntax/parser"
SS = require "../../syntax/ss_nodes"
DF = require "./df_nodes"

Snd = (_,y) ->y
Colon  = new TP.DelimLike(new SS.ColonToken)
Equals = new TP.DelimLike(new SS.DelimToken("="))


# For now, only idents can be variable names. TODO dollar signs
VariableName = new TP.Ident((x)->new DF.VariableName(x.value))

# For now, only a variable with type can be used. TODO type inference
Definable = VariableName

# A definable (variable or function) and a type name:
#
#     x:string
#
# Contrary to VDS annotations, here no bracketed inline types are allowed. We want to
# extend the named type, and extending an inline type makes no sense.
DefinableWithType = new TP.Juxtaposition(
  Definable,
  new TP.Juxtaposition(
    Colon,
    new TP.Ident,
    Snd
  ),
  (variableName,typeName) -> [variableName,typeName]
)

# A definition is a definable, an equals sign and a value.
#
#     x:string = "hello"
#
# The value must be of the definition type.
VariableDefinition = new TP.Juxtaposition(
  DefinableWithType,
  new TP.Juxtaposition(
    Equals,
    new TP.RawTokens(),
    Snd
  ),
  ([pattern, typeName], rawValue)-> new DF.Definition(pattern, typeName, rawValue)
)

# For now, only variables are defined. TODO function definitions
Definition = VariableDefinition

module.exports = Definition
