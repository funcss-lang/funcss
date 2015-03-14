Tokenizer = require "./tokenizer"
Parser = require "./parser"

exports.compile = (input) ->
  tokens = Tokenizer.tokenize(input)
  stylesheet = Parser.parse_stylesheet(tokens)
  return stylesheet.toString()


  
