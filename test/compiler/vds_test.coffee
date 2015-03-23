
TP = require "../../src/compiler/types"
Stream = require "../../src/compiler/stream"
Parser = require "../../src/compiler/parser"
Vds = require "../../src/compiler/vds"
check = require "./check"

check_value = (str, typeStr, next, value) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  type = Vds.parse(new Stream(Parser.parse_list_of_component_values(typeStr)))
  t = type.parse(s)
  t.should.be.equal(value)
  s.position.should.be.equal(next)

check_tree = (str, typeStr, next, args...) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  type = Vds.parse(new Stream(Parser.parse_list_of_component_values(typeStr)))
  t = type.parse(s)
  check t, args...
  s.position.should.be.equal(next)

check_nomatch = (str, typeStr, pos, message) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  type = Vds.parse(new Stream(Parser.parse_list_of_component_values(typeStr)))
  check.error TP.NoMatch, message: message, ->
    t = type.parse(s)
  s.position.should.be.equal(pos)

check_error = (str, typeStr, errorClass, message) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  check.error errorClass, message: message, ->
    type = Vds.parse(new Stream(Parser.parse_list_of_component_values(typeStr)))
    t = type.parse(s)

describe "Value Definition Syntax", ->
  describe "identType", ->
    it "can parse ident", ->
      check_value "asdf", "asdf", 1, "asdf"
    it "cannot parse sth", ->
      check_nomatch "3px", "asdf", 0, "'asdf' expected but '3px' found"

  describe "ident", ->
    it "can parse an ident", ->
      check_value "asdf", "<ident>", 1, "asdf"
    it "cannot parse sth", ->
      check_nomatch "3px", "<ident>", 0, "identifier expected but '3px' found"
    it "cannot use unnamed type", ->
      check_error "3px", "<asdf>", Vds.UnknownType, "unknown type <asdf>"

  describe "plus", ->
    it "can parse one"



