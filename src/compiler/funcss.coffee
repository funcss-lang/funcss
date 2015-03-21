Parser = require "./parser"
Optimizer = require "./optimizer"
SS = require "./stylesheet"
JS = require "./javascript"

exports.compile = (input) ->
  stylesheet = Parser.parse_stylesheet(input)
  script = new JS.JavaScript()
  script.push new JS.InsertStylesheet(stylesheet)

  script = Optimizer(script)

  return script.toString()


  
