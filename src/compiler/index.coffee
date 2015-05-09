Syntax    = require "./syntax"
Semantics = require "./semantics"
Generator = require "./generator"

exports.compile = (str) ->
  ss = Syntax(str)
  fs = Semantics(ss)
  ig = Generator(fs)
  ig.toString()


  
