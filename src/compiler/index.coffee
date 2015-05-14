Syntax    = require "./syntax"
Semantics = require "./semantics"
Generator = require "./generator"

exports.compile = (str, options) ->
  ss = Syntax(str, options)
  fs = Semantics(ss, options)
  ig = Generator(fs, options)
  ig.toString()


  
