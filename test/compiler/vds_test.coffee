# This file tests both the VDS grammar and the `js()` feature of the LLL.
TP = require "../../src/compiler/semantics/values/tp_nodes"
Stream = require "../../src/compiler/helpers/stream"
Parser = require "../../src/compiler/syntax/parser"
Vds = require "../../src/compiler/semantics/values/vds"
VL = require "../../src/compiler/semantics/values/vl_nodes"
check = require "./check"

customFunctions =
  abs: Math.abs
  sign: Math.sign
  sqrt: Math.sqrt

parse = (s, typeStr) ->
  type = Vds.parse(new Stream(Parser.parse_list_of_component_values(typeStr)))
  type.setTypeTable(Vds.TYPES)
  value = type.parse(s)
  value


check_tree = (str, typeStr, next, args...) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  t = parse(s, typeStr)
  check t, args...
  s.position.should.be.equal(next)
  t

check_nomatch = (str, typeStr, pos, message) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  check.error TP.NoMatch, message: message, ->
    parse(s, typeStr)
  s.position.should.be.equal(pos)

check_error = (str, typeStr, errorClass, message) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  check.error errorClass, message: message, ->
    type = Vds.parse(new Stream(Parser.parse_list_of_component_values(typeStr)))
    type.setTypeTable(Vds.TYPES)
    t = type.parse(s)

describe "Vds", ->
  describe "keyword", ->
    it "can parse ident", ->
      check_tree "asdf", "asdf", 1, VL.Keyword, value: "asdf"
    it "cannot parse sth", ->
      check_nomatch "3px", "asdf", 0, "'asdf' expected but '3px' found"
    it "cannot parse EOF", ->
      check_nomatch "", "asdf", 0, "'asdf' expected but '' found"

  describe "type reference", ->
    it "works", ->
      check_tree "3%", "<percentage>", 1, VL.Percentage, value: 3
    it "can use whitespace", ->
      # TODO make this disallowed?
      #check_error "3%", "< percentage>", TP.NoMatch, /identifier expected but ' ' found/
      #check_error "3%", "<percentage >", TP.NoMatch, /'>' expected but ' ' found/
      check_tree "3%", "< percentage>", 1, VL.Percentage, value: 3
      check_tree "3%", "<percentage >", 1, VL.Percentage, value: 3
      check_tree "3%", "< percentage >", 1, VL.Percentage, value: 3
    it "cannot use unnamed type", ->
      check_error "3%", "<asdf>", TP.UnknownType, "unknown type <asdf>"

  describe "<ident>", ->
    it "can parse an ident", ->
      check_tree "asdf", "<ident>", 1, VL.Keyword, value: "asdf"
    it "cannot parse sth", ->
      check_nomatch "3px", "<ident>", 0, "identifier expected but '3px' found"

  describe "<number>", ->
    it "can parse a number", ->
      check_tree "3.14", "<number>", 1, VL.Number, value: 3.14
    it "can parse an integer", ->
      check_tree "3", "<number>", 1, VL.Number, value: 3
    it "cannot parse sth", ->
      check_nomatch "3px", "<number>", 0, "number expected but '3px' found"

  describe "<integer>", ->
    it "can parse an integer", ->
      # TODO VL.Integer?
      check_tree "3", "<integer>", 1, VL.Number, value: 3
    it "cannot parse a number", ->
      check_nomatch "3.14", "<integer>", 0, "integer expected but '3.14' found"
    it "cannot parse sth", ->
      check_nomatch "3px", "<integer>", 0, "integer expected but '3px' found"

  describe "delimiters", ->
    it "can parse a slash token", ->
      check_tree "/", "/", 1, VL.Keyword, value:"/"
    it "can parse a comma token", ->
      check_tree ",", ",", 1, VL.Keyword, value: ","
    describe "cannot parse sth", ->
      specify "with '/'", ->
        check_nomatch "3px", "/", 0, "'/' expected but '3px' found"
      specify "with ','", ->
        check_nomatch "3px", ",", 0, "',' expected but '3px' found"

  describe "<percentage>", ->
    it "can parse a percentage", ->
      check_tree "3%", "<percentage>", 1, VL.Percentage, value: 3
    it "cannot parse a number", ->
      check_nomatch "3.14", "<percentage>", 0, "percentage expected but '3.14' found"
    it "cannot parse sth", ->
      check_nomatch "3px", "<percentage>", 0, "percentage expected but '3px' found"

  describe "<string>", ->
    it "can parse a string", ->
      check_tree "'asdf'", "<string>", 1, VL.String, value: "asdf"
    it "can parse a string with doulbe quotes", ->
      check_tree '"asdf"', "<string>", 1, VL.String, value: "asdf"
    it "cannot parse a number", ->
      check_nomatch "3.14", "<string>", 0, "string expected but '3.14' found"
    it "cannot parse sth", ->
      check_nomatch "3px", "<string>", 0, "string expected but '3px' found"


  describe "Juxtaposition", ->
    it "works", ->
      t = check_tree "black 3.3", "black <number>", 3, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Keyword, value: "black"
      check t.value[1], VL.Number, value:3.3
    it "works with three elements", ->
      t = check_tree "black 3.3 12%", "black <number> <percentage>", 5, VL.Collection, delimiter: " "
      check t.value, Array, length: 3
      check t.value[0], VL.Keyword, value: "black"
      check t.value[1], VL.Number, value: 3.3
      check t.value[2], VL.Percentage, value: 12
      t = check_tree "black 3.3 12%", "[black <number> <percentage>]", 5, VL.Collection, delimiter: " "
      check t.value, Array, length: 3
      check t.value[0], VL.Keyword, value: "black"
      check t.value[1], VL.Number, value: 3.3
      check t.value[2], VL.Percentage, value: 12
    it "works with three elements grouped 1-2", ->
      t = check_tree "black 3.3 12%", "[black <number>] <percentage>", 5, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Collection, delimiter: " "
      check t.value[0].value, Array, length: 2
      check t.value[0].value[0], VL.Keyword, value: "black"
      check t.value[0].value[1], VL.Number, value: 3.3
      check t.value[1], VL.Percentage, value: 12
    it "works with three elements grouped 2-3", ->
      t = check_tree "black 3.3 12%", "black [<number> <percentage>]", 5, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Keyword, value: "black"
      check t.value[1], VL.Collection, delimiter: " "
      check t.value[1].value, Array, length: 2
      check t.value[1].value[0], VL.Number, value: 3.3
      check t.value[1].value[1], VL.Percentage, value: 12
    it "fails for first bad type", ->
      check_nomatch "green 3.3", "black <number>", 0, "'black' expected but 'green' found"
    it "fails for first EOF", ->
      check_nomatch "", "black <number>", 0, "'black' expected but '' found"
      check_nomatch "", "black <number> asdf", 0, "'black' expected but '' found"
      check_nomatch "", "black <number> <percentage>", 0, "'black' expected but '' found"
      check_nomatch "", "[black <number>] <percentage>", 0, "'black' expected but '' found"
      check_nomatch "", "black [<number> <percentage>]", 0, "'black' expected but '' found"
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
      check_nomatch "black 3.3 ", "black [<number> <percentage>]", 4, "percentage expected but '' found"
      check_nomatch "black 3.3 ", "[black <number>] <percentage>", 4, "percentage expected but '' found"
      check_nomatch "black 3.3 ", "[black <number> <percentage>]", 4, "percentage expected but '' found"

  describe "double ampersand", ->
    it "works forward", ->
      t = check_tree "black 3.3", "black && <number>", 3, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Keyword, value: "black"
      check t.value[1], VL.Number, value: 3.3
    it "works backwards", ->
      t = check_tree "3.3 black", "black && <number>", 3, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Keyword, value: "black"
      check t.value[1], VL.Number, value: 3.3
    it "fails for first", ->
      check_nomatch "black", "black && <number>", 1, "number expected but '' found"
    it "fails for second", ->
      check_nomatch "3.3", "black && <number>", 1, "'black' expected but '' found"
    it "fails for empty", ->
      check_nomatch "", "black && <number>", 0, "'black' or number expected but '' found"

  describe "double bar", ->
    it "works forward", ->
      t = check_tree "black 3.3", "black || <number>", 3, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Keyword, value: "black"
      check t.value[1], VL.Number, value: 3.3
    it "works backwards", ->
      t = check_tree "3.3 black", "black || <number>", 3, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Keyword, value: "black"
      check t.value[1], VL.Number, value: 3.3
    it "works for first", ->
      t = check_tree "black", "black || <number>", 1, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Keyword, value: "black"
      check t.value[1], VL.EmptyValue
    it "works for second", ->
      t = check_tree "3.3", "black || <number>", 1, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.EmptyValue
      check t.value[1], VL.Number, value: 3.3
    it "fails for empty", ->
      check_nomatch "", "black || <number>", 0, "'black' or number expected but '' found"
      check_nomatch "", "black || [<number>]", 0, "'black' or number expected but '' found"
      check_nomatch "", "[[black] || [<number>]]", 0, "'black' or number expected but '' found"

  describe "Bar", ->
    it "works for first", ->
      t = check_tree "black", "black | <number>", 1, VL.Keyword, value: "black"
    it "works for second", ->
      t = check_tree "3.3", "black | <number>", 1, VL.Number, value: 3.3
    it "fails for empty", ->
      check_nomatch "", "black | <number>", 0, "'black' or number expected but '' found"
      check_nomatch "", "[black] | <number>", 0, "'black' or number expected but '' found"
      check_nomatch "", "[[[black] | <number>]]", 0, "'black' or number expected but '' found"

  describe "Asterisk", ->
    it "works for none", ->
      t = check_tree "", "<number>*", 0, VL.Collection, delimiter: " "
      check t.value, Array, length: 0
    it "works for one", ->
      t = check_tree "1", "<number>*", 1, VL.Collection, delimiter: " "
      check t.value, Array, length: 1
      check t.value[0], VL.Number, value: 1
    it "works for two", ->
      t = check_tree "1 2", "<number>*", 3, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Number, value: 1
      check t.value[1], VL.Number, value: 2
    it "works for three", ->
      t = check_tree "1 2 3", "<number>*", 5, VL.Collection, delimiter: " "
      check t.value, Array, length: 3
      check t.value[0], VL.Number, value: 1
      check t.value[1], VL.Number, value: 2
      check t.value[2], VL.Number, value: 3
    it "works for sth", ->
      t = check_tree "black", "<number>*", 0, VL.Collection, delimiter: " "
      check t.value, Array, length: 0

  describe "Plus", ->
    it "fails for none", ->
      check_nomatch "", "<number>+", 0, "number expected but '' found"
      check_nomatch "", "[<number>+]", 0, "number expected but '' found"
      check_nomatch "", "[<number>]+", 0, "number expected but '' found"
    it "works for one", ->
      t = check_tree "1", "<number>+", 1, VL.Collection, delimiter: " "
      check t.value, Array, length: 1
      check t.value[0], VL.Number, value: 1
      t = check_tree "1", "[<number>+]", 1, VL.Collection, delimiter: " "
      check t.value, Array, length: 1
      check t.value[0], VL.Number, value: 1
      t = check_tree "1", "[<number>]+", 1, VL.Collection, delimiter: " "
      check t.value, Array, length: 1
      check t.value[0], VL.Number, value: 1
    it "works for two", ->
      t = check_tree "1 2", "<number>+", 3, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Number, value: 1
      check t.value[1], VL.Number, value: 2
    it "works for three", ->
      t = check_tree "1 2 3", "<number>+", 5, VL.Collection, delimiter: " "
      check t.value, Array, length: 3
      check t.value[0], VL.Number, value: 1
      check t.value[1], VL.Number, value: 2
      check t.value[2], VL.Number, value: 3
    it "fails for sth", ->
      check_nomatch "black", "<number>+", 0, "number expected but 'black' found"

  describe "QuestionMark", ->
    it "works for none", ->
      check_tree "", "<number>?", 0, VL.EmptyValue
    it "works for one", ->
      t = check_tree "1", "<number>?", 1, VL.Number, value: 1
    it "works for two", ->
      t = check_tree "1 2", "<number>?", 1, VL.Number, value: 1
    it "works for sth", ->
      check_tree "black", "<number>?", 0, VL.EmptyValue

  describe "Range", ->
    it "works for none", ->
      check_nomatch "", "<number>{1,3}", 0, "number expected but '' found"
      check_nomatch "", "[<number>]{1,3}", 0, "number expected but '' found"
      check_nomatch "", "[<number>{1,3}]", 0, "number expected but '' found"
    it "works for one", ->
      t = check_tree "1", "<number>{1,3}", 1, VL.Collection, delimiter: " "
      check t.value, Array, length: 1
      check t.value[0], VL.Number, value: 1
    it "works for two", ->
      t = check_tree "1 2", "<number>{1,3}", 3, VL.Collection, delimiter: " "
      check t.value, Array, length: 2
      check t.value[0], VL.Number, value: 1
      check t.value[1], VL.Number, value: 2
    it "works for three", ->
      t = check_tree "1 2 3", "<number>{1,3}", 5, VL.Collection, delimiter: " "
      check t.value, Array, length: 3
      check t.value[0], VL.Number, value: 1
      check t.value[1], VL.Number, value: 2
      check t.value[2], VL.Number, value: 3
    it "works for four", ->
      t = check_tree "1 2 3 4", "<number>{1,3}", 6, VL.Collection, delimiter: " "
      check t.value, Array, length: 3
      check t.value[0], VL.Number, value: 1
      check t.value[1], VL.Number, value: 2
      check t.value[2], VL.Number, value: 3
    it "fails for sth", ->
      check_nomatch "black", "<number>{1,3}", 0, "number expected but 'black' found"

  describe "Hashmark", ->
    it "fails for none", ->
      check_nomatch "", "<number>#", 0, "number expected but '' found"
    it "works for one", ->
      t = check_tree "1", "<number>#", 1, VL.Collection, delimiter: ", "
      check t.value, Array, length: 1
      check t.value[0], VL.Number, value: 1
    it "works for two", ->
      t = check_tree "1, 2", "<number>#", 4, VL.Collection, delimiter: ", "
      check t.value, Array, length: 2
      check t.value[0], VL.Number, value: 1
      check t.value[1], VL.Number, value: 2
    it "works for three", ->
      t = check_tree "1 ,2, 3", "<number>#", 7, VL.Collection, delimiter: ", "
      check t.value, Array, length: 3
      check t.value[0], VL.Number, value: 1
      check t.value[1], VL.Number, value: 2
      check t.value[2], VL.Number, value: 3
    it "fails for sth", ->
      check_nomatch "black", "<number>#", 0, "number expected but 'black' found"






