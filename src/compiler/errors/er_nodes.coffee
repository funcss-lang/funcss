## Error nodes
#
# This is not actually a tree, but individual objects.

ER = exports


class ER.FunCSSError extends Error
  constructor: (@message) ->
    @stack = @message + "\n" + (new Error()).stack
  setup: (@message) ->
    @stack = @message + "\n" + (new Error()).stack

class ER.TypeError extends ER.FunCSSError

class ER.SyntaxError extends ER.FunCSSError

class ER.UnknownAtRule extends ER.FunCSSError
  constructor: (@name) ->
    @setup "Unknown at rule: #{@name}"

class ER.BlockRequired extends ER.SyntaxError
  constructor: (@name) ->
    @setup "Block required for #{@name}"

class ER.BlockRequired extends ER.SyntaxError
  constructor: (@name) ->
    @setup "Block not allowed for #{@name}"

class ER.TypeInferenceNotImplemented extends ER.TypeError
  constructor: (@definable) ->
    @setup  "Automatic type inference is not yet implemented. Please provide an explicit type for #{@definable}"
    
class ER.NotImplemented extends ER.TypeError
  constructor: (@message) ->
    @setup  @message

class ER.UnknownAtRule extends ER.SyntaxError
  constructor: (@atRuleName) ->
    @setup "Unknown at-rule: #{@atRuleName}"

class ER.UnknownProperty extends ER.TypeError
  constructor: (@propertyName) ->
    @setup "Unknown property: #{@propertyName}"
    

class ER.UnknownType extends ER.TypeError
  constructor: (@typeName) ->
    @setup "Unknown type: #{@typeName}"
    
class ER.DecodingNotSupported extends ER.TypeError
  constructor: (@type) ->
    @setup "Decoding from JS is not supported for type #{@type}"

class ER.InvalidColor extends ER.TypeError
  constructor: (@color) ->
    @setup "Invalid color: #{@color}"

class ER.IncludeFileNotFound extends ER.TypeError
  constructor: (@fileName) ->
    @setup "Include file not found: #{@fileName}"
