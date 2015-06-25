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


FunctionalNotation = new GR.AnyFunctionalNotation(
  VdsGrammar.OptionalRoot,
  (name, argument)->new DF.FunctionalNotation(name, argument)
)

#Dimension = new GR.Dimension(
  #(x)->new DF.Dimension(x.value, x.unit)
#)

Definable = new GR.ExclusiveOr(
  VariableName,
  #new GR.ExclusiveOr(
  FunctionalNotation
    #,Dimension
  #)
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
  (definable,typeName) -> [definable,typeName]
)


# A definition is a definable, an equals sign and a value.
#
#     x:string = "hello"
#
# The value must be of the definition type.
SignatureWithOptionalDefinition = new GR.Juxtaposition(
  DefinableWithOptionalType,
  new GR.Optional(
    new GR.Juxtaposition(
      Equals,
      new GR.RawTokens(),
      Snd
    )
  ),
  ([definable, typeName], rawValue)-> new DF.Definition(definable, typeName, rawValue)
)

# For now, only variables are defined. TODO JS definitions
DefinitionPrelude = SignatureWithOptionalDefinition


# This is the main entry point, for taking into account blocks and empty statements

exports.parseStatement = (s) ->
  def = new GR.Optional(DefinitionPrelude).parse(s.prelude)
  if def?
    if def.rawValue? and s.block?
      throw new ER.SyntaxError "Definition has both CSS and JS body. #{s}"
    def.block = s.block
    def

exports.parse = (str) ->
  @parseStatement(Parser.parse_a_statement(str))


