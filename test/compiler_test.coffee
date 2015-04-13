Compiler = require "../src/compiler"

check_compile = (s,result) ->
  Compiler.compile(s).should.equal(result)

describe "Compiler", ->
  it "compiles '' to ''", ->
    check_compile "", ""
