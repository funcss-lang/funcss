Parser = require "./parser"
N = require "./nodes"

exports.compile = (input) ->
  stylesheet = Parser.parse_stylesheet(input)
  script = new N.Script()
  script.push new N.InsertStylesheet(stylesheet)
  return script.toString()


  
