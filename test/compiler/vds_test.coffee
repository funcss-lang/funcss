
Types = require "#{__dirname}/../../src/compiler/types"
Stream = require "#{__dirname}/../../src/compiler/stream"
Parser = require("#{__dirname}/../../src/compiler/parser.coffee")
Vds = require "#{__dirname}/../../src/compiler/vds"
check = require "#{__dirname}/../check"

check_value = (str, typeStr, next, value) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  type = Vds(new Stream(Parser.parse_list_of_component_values(typeStr)))
  t = type(s)
  t.should.be.equal(value)
  s.position.should.be.equal(next)

check_tree = (str, typeStr, next, args...) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  type = Vds(new Stream(Parser.parse_list_of_component_values(typeStr)))
  t = type(s)
  check t, args...
  s.position.should.be.equal(next)

check_error = (str, typeStr, pos, message) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  type = Vds(new Stream(Parser.parse_list_of_component_values(typeStr)))
  check.error Types.NoMatch, message: message, ->
    t = type(s)
  s.position.should.be.equal(pos)


describe "Value Definition Syntax", ->
  describe "identType", ->
    it "can parse ident", ->
      debugger
      check_value "asdf", "asdf", 1, "asdf"
    it "cannot parse sth", ->
      check_error "3px", "asdf", 0, "'asdf' expected but '3px' found"

  describe "plus", ->
    it "can parse one"



