Syntax    = require "./syntax"
Semantics = require "./semantics"
Generator = require "./generator"

exports.compile = (str) ->
  ss = Syntax(str)
  sg = Semantics(ss)
  ig = Generator(sg)
  ig.toString()


  
