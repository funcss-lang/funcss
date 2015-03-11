# These are the tests for the code generator.
#

N = require "../../src/compiler/nodes"
Parser = require("#{__dirname}/../../src/compiler/parser.coffee")


check_ser = (orig, result) ->
  values = Parser.parse_list_of_component_values(orig)


describe "Nodes", ->
  describe "Serializer", ->

