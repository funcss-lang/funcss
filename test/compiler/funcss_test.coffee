FunCSS = require "../../src/compiler/funcss.coffee"

check_compile = (s,result) ->
  FunCSS.compile(s).should.equal(result)


