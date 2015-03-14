Parser = require "./parser"
Optimizer = require "./optimizer"
N = require "./nodes"

exports.compile = (input) ->
  stylesheet = Parser.parse_stylesheet(input)
  script = new N.Script()
  script.push new N.InsertStylesheet(stylesheet)

  script = Optimizer(script)

  return script.toString()


  
