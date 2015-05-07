GR = require "../../syntax/gr_nodes"
Parser = require "../../syntax/parser"
SS = require "../../syntax/ss_nodes"
DF = require "./df_nodes"

Snd = (_,y) ->y
Colon  = new GR.DelimLike(new SS.ColonToken)
Equals = new GR.DelimLike(new SS.DelimToken("="))


# For now, only idents can be variable names. TODO dollar signs
VariableName = new GR.Ident((x)->new DF.VariableName(x.value))

# For now, only a variable with type can be used. TODO type inference
Definable = VariableName

# A definable (variable or function) and a type name:
#
#     x:string
#
# Contrary to VDS annotations, here no bracketed inline types are allowed. We want to
# extend the named type, and extending an inline type makes no sense.
DefinableWithType = new GR.Juxtaposition(
  Definable,
  new GR.Juxtaposition(
    Colon,
    new GR.Ident,
    Snd
  ),
  (variableName,typeName) -> [variableName,typeName]
)

# A definition is a definable, an equals sign and a value.
#
#     x:string = "hello"
#
# The value must be of the definition type.
VariableDefinition = new GR.Juxtaposition(
  DefinableWithType,
  new GR.Juxtaposition(
    Equals,
    new GR.RawTokens(),
    Snd
  ),
  ([pattern, typeName], rawValue)-> new DF.Definition(pattern, typeName, rawValue)
)

# For now, only variables are defined. TODO function definitions
Definition = VariableDefinition

module.exports = Definition
