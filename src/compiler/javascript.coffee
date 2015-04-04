#### JavaScript nodes
#

# The base class for all JS nodes
exports.Base = class Base

#
# `JavaScript` is the main script class that outputs the target code.
exports.JavaScript = class JavaScript extends Base
  @prototype: []
  toString: -> if @length then """
    !function(){
    #{@join('\n')}
    }();
  """ else ""

# Insert a stylesheet to the `head`, and save it to `var S`
#
exports.InsertStylesheet = class InsertStylesheet extends Base
  constructor: (@value) ->
  toString: -> """
    var S = document.createElement("style");
    S.innerHTML=#{JSON.stringify("#{@value}")};
    document.head.appendChild(S);
  """

exports.Statement = class Statement extends Base
exports.Expression = class Expression extends Statement

# Things that always mean the same
exports.Literal = class Literal extends Expression
  constructor: (@value) ->
  
  toString: ->
    "#{@value}"

  

