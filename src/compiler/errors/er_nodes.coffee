## Error nodes
#
# This is not actually a tree, but individual objects.

ER = exports


class ER.FunCSSError extends Error
  constructor: (@message) ->
    @stack = @message + "\n" + (new Error()).stack

class ER.TypeError extends ER.FunCSSError

class ER.SyntaxError extends ER.FunCSSError

class ER.UnknownAtRule extends ER.FunCSSError
  constructor: (@name) ->
    super "Unknown at rule: #{@name}"

class ER.BlockRequired extends ER.SyntaxError
  constructor: (@name) ->
    super "Block required for #{@name}"

class ER.TypeInferenceNotImplemented extends ER.TypeError
  constructor: (@definable) ->
    super  "Automatic type inference is not yet implemented. Please provide an explicit type for #{@definable}"
    
class ER.NotImplemented extends ER.TypeError
  constructor: (@message) ->
    super  @message

class ER.UnknownAtRule extends ER.SyntaxError
  constructor: (@atRuleName) ->
    super "Unknown at-rule: #{@atRuleName}"

class ER.UnknownProperty extends ER.TypeError
  constructor: (@propertyName) ->
    super "Unknown property: #{@propertyName}"
    

class ER.UnknownType extends ER.TypeError
  constructor: (@typeName) ->
    super "Unknown type: #{@typeName}"
    
class ER.DecodingNotSupported extends ER.TypeError
  constructor: (@type) ->
    super "Decoding from JS is not supported for type #{@type}"

class ER.InvalidColor extends ER.TypeError
  constructor: (@color) ->
    super "Invalid color: #{@color}"
