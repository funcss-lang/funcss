Parser = require "./parser"
Optimizer = require "./optimizer"
SS = require "./stylesheet"

exports.compile = (input) ->
  stylesheet = Parser.parse_stylesheet(input)
  script = new SS.Script()
  script.push new SS.InsertStylesheet(stylesheet)

  script = Optimizer(script)

  return script.toString()


  
