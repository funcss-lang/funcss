Syntax    = require "./syntax"
Semantics = require "./semantics"
Generator = require "./generator"

exports.compile = (str) ->
  ss = Syntax(str)
  sg = Semantics(ss)
  js = Generator(sg)
  js.toString()


  
