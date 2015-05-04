# These nodes represent the AST of the body of the @def at-rule.


# The subclasses of the `Pattern` class represent those patterns that can
# be defined. These compile to a TP node.

exports.Definable = class Definable

#
# This represents a variable name. TODO it should support dollar signs
exports.VariableName = class VariableName extends Definable
  constructor: (@value) ->

exports.Definition = class Definition
  constructor: (@definable, @type, @rawValue) ->


