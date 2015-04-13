Syntax = require "./compiler/syntax"
Semantics = require "./compiler/semantics"
Generator = require "./compiler/generator"

exports.compile = (str) ->
  ss = Syntax(str)
  sg = Semantics(ss)
  js = Generator(sg)
  js.toString()


  
