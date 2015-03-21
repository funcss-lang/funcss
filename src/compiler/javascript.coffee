#### JavaScript nodes
#
# These nodes are mostly named as verbs, based on what they do.
#
# `JavaScript` is the main script class that outputs the target code.
exports.JavaScript = class JavaScript
  @prototype: []
  toString: -> if @length then """
    !function(){
    #{@join('\n')}
    }();
  """ else ""

# Insert a stylesheet to the `head`, and save it to `var S`
#
exports.InsertStylesheet = class InsertStylesheet
  constructor: (@value) ->
  toString: -> """
    var S = document.createElement("style");
    S.innerHTML=#{JSON.stringify("#{@value}")};
    document.head.appendChild(S);
  """

exports.InsertJQReact = class InsertJQReact
  constructor: () ->
  toString: ->

