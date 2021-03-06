# This file tests both the VDS grammar and the `js()` feature of the LLL.
GR = require "../../src/compiler/semantics/../syntax/gr_nodes"
Parser = require "../../src/compiler/syntax/parser"
VdsGrammar = require "../../src/compiler/semantics/values/vds_grammar"
check = require "./check"
FS = require "../../src/compiler/semantics/fs_nodes"

customFunctions =
  abs: Math.abs
  sign: Math.sign
  sqrt: Math.sqrt

parse = (str, typeStr) ->
  type = VdsGrammar.parse(typeStr)
  type.setFs(new FS.FunctionalStylesheet())
  value = type.parse(str)
  jsjs = value.jsjs()
  eval("#{jsjs}")


check_value = (str, typeStr, next, value) ->
  t = parse(str, typeStr)
  t.should.equal(value) unless t is undefined and value is undefined

check_tree = (str, typeStr, next, args...) ->
  t = parse(str, typeStr)
  check t, args...
  t

check_nomatch = (str, typeStr, pos, message) ->
  check.error GR.NoMatch, message: message, ->
    parse(str, typeStr)

check_error = (str, typeStr, errorClass, message) ->
  check.error errorClass, message: message, ->
    type = VdsGrammar.parse(typeStr)
    type.setFs(new FS.FunctionalStylesheet())
    t = type.parse(str)

describe "Jsjs", ->
  describe "keyword", ->
    it "can parse ident", ->
      check_value "asdf", "asdf", 1, "asdf"
    it "cannot parse sth", ->
      check_nomatch "3px", "asdf", 0, "'asdf' expected but '3px' found"
    it "cannot parse EOF", ->
      check_nomatch "", "asdf", 0, "'asdf' expected but '' found"

  describe "type reference", ->
    it "works", ->
      check_value "3%", "<percentage>", 1, 0.03

  describe "<ident>", ->
    it "can parse an ident", ->
      check_value "asdf", "<ident>", 1, "asdf"

  describe "<number>", ->
    it "can parse a number", ->
      check_value "3.14", "<number>", 1, 3.14
    it "can parse an integer", ->
      check_value "3", "<number>", 1, 3

  describe "<integer>", ->
    it "can parse an integer", ->
      check_value "3", "<integer>", 1, 3

  describe "delimiters", ->
    it "can parse a slash token", ->
      check_value "/", "/", 1, "/"
    it "can parse a comma token", ->
      check_value ",", ",", 1, ","

  describe "<percentage>", ->
    it "can parse a percentage", ->
      check_value "3%", "<percentage>", 1, 0.03

  describe "<string>", ->
    it "can parse a string", ->
      check_value "'asdf'", "<string>", 1, "asdf"
    it "can parse a string with doulbe quotes", ->
      check_value '"asdf"', "<string>", 1, "asdf"


  describe "Juxtaposition", ->
    it "works", ->
      check_tree "black 3.3", "black <number>", 3, Array, length: 2, 0:"black", 1:3.3
    it "works with three elements", ->
      check_tree "black 3.3 12%", "black <number> <percentage>", 5, Array, length: 3, 0:"black", 1:3.3, 2:0.12
      check_tree "black 3.3 12%", "[black <number> <percentage>]", 5, Array, length: 3, 0:"black", 1:3.3, 2:0.12
    it "works with three elements grouped 1-2", ->
      t = check_tree "black 3.3 12%", "[black <number>] <percentage>", 5, Array, length: 2, 1:0.12
      check t[0], Array, length: 2, 0:"black", 1:3.3
    it "works with three elements grouped 2-3", ->
      t = check_tree "black 3.3 12%", "black [<number> <percentage>]", 5, Array, length: 2, 0:"black"
      check t[1], Array, length: 2, 0:3.3, 1:0.12
    it "fails for first bad type", ->
      check_nomatch "green 3.3", "black <number>", 0, "'black' expected but 'green' found"

  describe "double ampersand", ->
    it "works forward", ->
      check_tree "black 3.3", "black && <number>", 3, Array, length: 2, 0:"black", 1:3.3
    it "works backwards", ->
      check_tree "3.3 black", "black && <number>", 3, Array, length: 2, 0:"black", 1:3.3
    it "fails for first", ->
      check_nomatch "black", "black && <number>", 1, "number expected but '' found"
    it "fails for second", ->
      check_nomatch "3.3", "black && <number>", 1, "'black' expected but '' found"
    it "fails for empty", ->
      check_nomatch "", "black && <number>", 0, "'black' or number expected but '' found"

  describe "double bar", ->
    it "works forward", ->
      check_tree "black 3.3", "black || <number>", 3, Array, length: 2, 0:"black", 1:3.3
    it "works backwards", ->
      check_tree "3.3 black", "black || <number>", 3, Array, length: 2, 0:"black", 1:3.3
    it "works for first", ->
      check_tree "black", "black || <number>", 1, Array, length: 2, 0:"black", 1:undefined
    it "works for second", ->
      check_tree "3.3", "black || <number>", 1, Array, length: 2, 0:undefined, 1:3.3

  describe "Bar", ->
    it "works for first", ->
      check_value "black", "black | <number>", 1, "black"
    it "works for second", ->
      check_value "3.3", "black | <number>", 1, 3.3

  describe "Asterisk", ->
    it "works for none", ->
      check_tree "", "<number>*", 0, Array, length: 0
    it "works for one", ->
      check_tree "1", "<number>*", 1, Array, length: 1, 0:1
    it "works for two", ->
      check_tree "1 2", "<number>*", 3, Array, length: 2, 0:1, 1:2
    it "works for three", ->
      check_tree "1 2 3", "<number>*", 5, Array, length: 3, 0:1, 1:2, 2:3

  describe "Plus", ->
    it "works for one", ->
      check_tree "1", "<number>+", 1, Array, length: 1, 0:1
      check_tree "1", "[<number>+]", 1, Array, length: 1, 0:1
      check_tree "1", "[<number>]+", 1, Array, length: 1, 0:1
    it "works for two", ->
      check_tree "1 2", "<number>+", 3, Array, length: 2, 0:1, 1:2
    it "works for three", ->
      check_tree "1 2 3", "<number>+", 5, Array, length: 3, 0:1, 1:2, 2:3

  describe "QuestionMark", ->
    it "works for none", ->
      check_value "", "<number>?", 0, undefined
    it "works for one", ->
      check_value "3.3", "<number>?", 1, 3.3

  describe "Range", ->
    it "works for one", ->
      check_tree "1", "<number>{1,3}", 1, Array, length: 1, 0:1
    it "works for two", ->
      check_tree "1 2", "<number>{1,3}", 3, Array, length: 2, 0:1, 1:2
    it "works for three", ->
      check_tree "1 2 3", "<number>{1,3}", 5, Array, length: 3, 0:1, 1:2, 2:3

  describe "Hashmark", ->
    it "works for one", ->
      check_tree "1", "<number>#", 1, Array, length: 1, 0:1
    it "works for two", ->
      check_tree "1, 2", "<number>#", 4, Array, length: 2, 0:1, 1:2
    it "works for three", ->
      check_tree "1, 2,3", "<number>#", 6, Array, length: 3, 0:1, 1:2, 2:3


  describe "annotations", ->
    it "works for x:ident", ->
      check_tree "black", "color:ident", 1, Object, color:"black"
    it "works for x:[y:ident]", ->
      t = check_tree "hello", "x:[y:ident]", 1, Object
      check t.x, Object, y:"hello"
    it "works for $x:ident", ->
      check_tree "black", "$color:ident", 1, Object, $color:"black"
    it "works for $x:[$y:ident]", ->
      t = check_tree "hello", "$x:[$y:ident]", 1, Object
      check t.$x, Object, $y:"hello"
    it "works for $x:[y:ident]", ->
      t = check_tree "hello", "$x:[y:ident]", 1, Object
      check t.$x, Object, y:"hello"
    it "works for x:[a:[yes] b:[no]]", ->
      t = check_tree "yes no", "x:[a:[yes] b:[no]]", 3, Object
      check t.x, Object, a:"yes", b:"no"
    it "works for x:[a:[yes] && b:[no]]", ->
      t = check_tree "yes no", "x:[a:[yes] && b:[no]]", 3, Object
      check t.x, Object, a:"yes", b:"no"
      t = check_tree "no yes", "x:[a:[yes] && b:[no]]", 3, Object
      check t.x, Object, a:"yes", b:"no"

    describe "works for x:[a:[yes] || b:[no]]", ->
      specify "for 'yes no'", ->
        t = check_tree "yes no", "x:[a:[yes] || b:[no]]", 3, Object
        check t.x, Object, a:"yes", b:"no"
      specify "for 'no yes'", ->
        t = check_tree "no yes", "x:[a:[yes] || b:[no]]", 3, Object
        check t.x, Object, a:"yes", b:"no"
      specify "for 'no'", ->
        t = check_tree "no", "x:[a:[yes] || b:[no]]", 1, Object
        check t.x, Object, a:undefined, b:"no"
      specify "for 'yes'", ->
        t = check_tree "yes", "x:[a:[yes] || b:[no]]", 1, Object
        check t.x, Object, a:"yes", b:undefined

    describe "works for x:[a:[yes] | b:[no]]", ->
      specify "for 'no'", ->
        t = check_tree "no", "x:[a:[yes] | b:[no]]", 1, Object
        check t.x, Object, a:undefined, b:"no"
      specify "for 'yes'", ->
        t = check_tree "yes", "x:[a:[yes] | b:[no]]", 1, Object
        check t.x, Object, a:"yes", b:undefined

    describe "works for x:[a:[yes]|b:[no]]*", ->
      specify "for ''", ->
        t = check_tree "", "x:[[a:[yes]|b:[no]]*]", 0, Object
        check t.x, Array, length: 0
      specify "for 'yes'", ->
        t = check_tree "yes", "x:[[a:[yes]|b:[no]]*]", 1, Object
        check t.x, Array, length: 1
        check t.x[0], Object, a:"yes", b:undefined
      specify "for 'yes no'", ->
        t = check_tree "yes no", "x:[[a:[yes]|b:[no]]*]", 3, Object
        check t.x, Array, length: 2
        check t.x[0], Object, a:"yes", b:undefined
        check t.x[1], Object, a:undefined, b:"no"

    describe "works for x:[[a:[yes]|b:[no]]#]", ->
      specify "for 'yes'", ->
        t = check_tree "yes", "x:[[a:[yes]|b:[no]]#]", 1, Object
        check t.x, Array, length: 1
        check t.x[0], Object, a:"yes", b:undefined
      specify "for 'no,no,yes'", ->
        t = check_tree "no,no,yes", "x:[[a:[yes]|b:[no]]#]", 5, Object
        check t.x, Array, length: 3
        check t.x[0], Object, a:undefined, b:"no"
        check t.x[1], Object, a:undefined, b:"no"
        check t.x[2], Object, a:"yes", b:undefined

    describe "works for x:[[a:[yes]|b:[no]]?]", ->
      specify "for ''", ->
        check_tree "", "x:[[a:[yes]|b:[no]]?]", 0, Object, x:undefined
      specify "for 'no'", ->
        t = check_tree "no", "x:[[a:[yes]|b:[no]]?]", 1, Object
        check t.x, Object, a:undefined, b:"no"

    describe "works for x:[[a:[yes]||b:[no]]?]", ->
      specify "for ''", ->
        check_tree "", "x:[[a:[yes]||b:[no]]?]", 0, Object, x:undefined
      specify "for 'no'", ->
        t = check_tree "no", "x:[[a:[yes]||b:[no]]?]", 1, Object
        check t.x, Object, a:undefined, b:"no"
      specify "for 'yes'", ->
        t = check_tree "yes", "x:[[a:[yes]||b:[no]]?]", 1, Object
        check t.x, Object, a:"yes", b:undefined
      specify "for 'yes no'", ->
        t = check_tree "yes no", "x:[[a:[yes]||b:[no]]?]", 3, Object
        check t.x, Object, a:"yes", b:"no"
      specify "for 'no yes'", ->
        t = check_tree "no yes", "x:[[a:[yes]||b:[no]]?]", 3, Object
        check t.x, Object, a:"yes", b:"no"

    describe "works for [a:[yes]|b:[no]]*", ->
      specify "for ''", ->
        check_tree "", "[a:[yes]|b:[no]]*", 0, Array, length: 0
      specify "for 'yes'", ->
        t = check_tree "yes", "[a:[yes]|b:[no]]*", 1, Array, length: 1
        check t[0], Object, a:"yes", b:undefined
      specify "for 'yes no'", ->
        t = check_tree "yes no", "[a:[yes]|b:[no]]*", 3, Array, length: 2
        check t[0], Object, a:"yes", b:undefined
        check t[1], Object, a:undefined, b:"no"

  describe "functional notations", ->
    it "works for f(x)", ->
      check_value "abs(-5)", "abs(<number>)", 1, 5





