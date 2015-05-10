Parser     = require "../../syntax/parser"
SS         = require "../../syntax/ss_nodes"
GR         = require "../../syntax/gr_nodes"
VdsGrammar = require "../values/vds_grammar"
DF         = require "./df_nodes"

Snd = (_,y) ->y
Colon  = new GR.DelimLike(new SS.ColonToken)
Equals = new GR.DelimLike(new SS.DelimToken("="))
Dollar = new GR.DelimLike(new SS.DelimToken("$"))


# For now, only idents can be variable names. TODO dollar signs
VariableName = new GR.ExclusiveOr(
  new GR.Ident((x)->new DF.VariableName(x.value)),
  new GR.CloselyJuxtaposed(
    Dollar,
    new GR.Ident((x)->new DF.VariableName('$'+x.value)),
    Snd
  )
)


# For now, only idents can be variable names. TODO dollar signs
FunctionalNotation = new GR.AnyFunctionalNotation(
  VdsGrammar.OptionalRoot,
  (name, argument)->new DF.FunctionalNotation(name, argument)
)

# For now, only a variable with type can be used. 
Definable = new GR.ExclusiveOr(
  VariableName,
  FunctionalNotation
)

# A definable (variable or function) and a type name:
#
#     x:string
#
# Contrary to VDS annotations, here no bracketed inline types are allowed. We want to
# extend the named type, and extending an inline type makes no sense.
DefinableWithOptionalType = new GR.Juxtaposition(
  Definable,
  new GR.Optional(
    new GR.Juxtaposition(
      Colon,
      new GR.Ident,
      Snd
    )
  ),
  (variableName,typeName) -> [variableName,typeName]
)

# A definition is a definable, an equals sign and a value.
#
#     x:string = "hello"
#
# The value must be of the definition type.
DefinitionInStylesheet = new GR.Juxtaposition(
  DefinableWithOptionalType,
  new GR.Juxtaposition(
    Equals,
    new GR.RawTokens(),
    Snd
  ),
  ([pattern, typeName], rawValue)-> new DF.Definition(pattern, typeName, rawValue)
)

# For now, only variables are defined. TODO JS definitions
Definition = DefinitionInStylesheet

module.exports = Definition
