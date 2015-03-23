
TP = require "../../src/compiler/types"
Stream = require "../../src/compiler/stream"
Parser = require "../../src/compiler/parser"
Vds = require "../../src/compiler/vds"
check = require "./check"

check_value = (str, typeStr, next, value) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  type = Vds.parse(new Stream(Parser.parse_list_of_component_values(typeStr)))
  t = type.parse(s)
  t.should.equal(value) unless t is undefined and value is undefined
  s.position.should.be.equal(next)

check_tree = (str, typeStr, next, args...) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  type = Vds.parse(new Stream(Parser.parse_list_of_component_values(typeStr)))
  t = type.parse(s)
  check t, args...
  s.position.should.be.equal(next)
  t

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
    it "cannot parse EOF", ->
      check_nomatch "", "asdf", 0, "'asdf' expected but '' found"

  describe "type reference", ->
    it "cannot use unnamed type", ->
      check_error "3px", "<asdf>", Vds.UnknownType, "unknown type <asdf>"

  describe "<ident>", ->
    it "can parse an ident", ->
      check_value "asdf", "<ident>", 1, "asdf"
    it "cannot parse sth", ->
      check_nomatch "3px", "<ident>", 0, "identifier expected but '3px' found"

  describe "<number>", ->
    it "can parse a number", ->
      check_value "3.14", "<number>", 1, 3.14
    it "can parse an integer", ->
      check_value "3", "<number>", 1, 3
    it "cannot parse sth", ->
      check_nomatch "3px", "<number>", 0, "number expected but '3px' found"

  describe "<integer>", ->
    it "can parse an integer", ->
      check_value "3", "<integer>", 1, 3
    it "cannot parse a number", ->
      check_nomatch "3.14", "<integer>", 0, "integer expected but '3.14' found"
    it "cannot parse sth", ->
      check_nomatch "3px", "<integer>", 0, "integer expected but '3px' found"

  describe "delimiters", ->
    it "can parse a slash token", ->
      check_value "/", "/", 1, undefined
    it "can parse a comma token", ->
      check_value ",", ",", 1, undefined
    it "cannot parse sth", ->
      check_nomatch "3px", "/", 0, "'/' expected but '3px' found"
      check_nomatch "3px", ",", 0, "',' expected but '3px' found"

  describe "<percentage>", ->
    it "can parse a percentage", ->
      check_value "3%", "<percentage>", 1, 0.03
    it "cannot parse a number", ->
      check_nomatch "3.14", "<percentage>", 0, "percentage expected but '3.14' found"
    it "cannot parse sth", ->
      check_nomatch "3px", "<percentage>", 0, "percentage expected but '3px' found"

  describe "<string>", ->
    it "can parse a string", ->
      check_value "'asdf'", "<string>", 1, "asdf"
    it "can parse a string with doulbe quotes", ->
      check_value '"asdf"', "<string>", 1, "asdf"
    it "cannot parse a number", ->
      check_nomatch "3.14", "<string>", 0, "string expected but '3.14' found"
    it "cannot parse sth", ->
      check_nomatch "3px", "<string>", 0, "string expected but '3px' found"


  describe "Juxtaposition", ->
    it "works", ->
      check_tree "black 3.3", "black <number>", 3, Array, length: 2, 0:"black", 1:3.3
    it "works with three elements", ->
      check_tree "black 3.3 12%", "black <number> <percentage>", 5, Array, length: 3, 0:"black", 1:3.3, 2:0.12
    it "fails for first bad type", ->
      check_nomatch "green 3.3", "black <number>", 0, "'black' expected but 'green' found"
    it "fails for first EOF", ->
      check_nomatch "", "black <number>", 0, "'black' expected but '' found"
      check_nomatch "", "black <number> asdf", 0, "'black' expected but '' found"
      check_nomatch "", "black <number> <percentage>", 0, "'black' expected but '' found"
    it "fails for second EOF", ->
      check_nomatch "black", "black <number>", 1, "number expected but '' found"
    it "fails for second _EOF", ->
      check_nomatch "black    ", "black <number>", 2, "number expected but '' found"
    it "fails for second bad type", ->
      check_nomatch "black green", "black <number>", 2, "number expected but 'green' found"
    it "fails for third bad type", ->
      check_nomatch "black 3.3 sdf", "black <number> <percentage>", 4, "percentage expected but 'sdf' found"
    it "fails for third EOF", ->
      check_nomatch "black 3.3 ", "black <number> <percentage>", 4, "percentage expected but '' found"

  describe "annotations", ->
    it "works for x:hello", ->
      check_tree "black", "color:<ident>", 1, Object, color:"black"
    it "works for x:y:hello", ->
      t = check_tree "hello", "x:y:<ident>", 1, Object
      check t.x, Object, y:"hello"







