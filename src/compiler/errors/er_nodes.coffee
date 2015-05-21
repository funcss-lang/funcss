## Error nodes
#
# This is not actually a tree, but individual objects.

ER = exports


class ER.FunCSSError extends Error
  constructor: (@message) ->
    @stack = (new Error()).stack

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
  constructor: (@name) ->
    super "Unknown at-rule: #{@name}"

class ER.UnknownProperty extends ER.TypeError
  constructor: (@name) ->
    super "Unknown property: #{@name}"
    

class ER.UnknownType extends ER.TypeError
  constructor: (@name) ->
    super "Unknown type: #{@name}"
    
class ER.DecodingNotSupported extends ER.TypeError
  constructor: (@type) ->
    super "Decoding from JS is not supported for type #{@type}"
