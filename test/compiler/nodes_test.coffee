# These are the tests for the code generator.
#

N = require "../../src/compiler/nodes"
Parser = require("#{__dirname}/../../src/compiler/parser.coffee")


check_ser = (orig, result=orig) ->
  debugger
  values = Parser.parse_list_of_component_values(orig)
  (""+values).should.equal(result)


describe "Nodes", ->
  describe "Serializer", ->
    it("serializes '#{str}' correctly", do (str)->-> check_ser(str)) for str in [
      "asdf asdf"
      "asdf/**/asdf"
      "3px+"
      "+3px"
      "+/**/3px"
      "3cm"
      "3/**/cm"
      "3 cm"
      "3+cm"
      "3e+1"
      "3e-1"
      "3/**/e-1"
      "3e/**/-1"
      "3e-/**/1"
    ]
    it("serializes '#{str}' to '#{res}' correctly", do (str,res)->-> check_ser(str,res)) for [str,res] in [
      ["asdf    asdf", "asdf asdf"]
      ["asdf/* hello */asdf", "asdf/**/asdf"]
    ]

