Parser = require ".././syntax/parser"

module.exports = (input) ->
  Parser.parse_stylesheet(input)
