GR = require "../../src/compiler/semantics/../syntax/gr_nodes"
Stream = require "../../src/compiler/helpers/stream"
Parser = require "../../src/compiler/syntax/parser"
VdsGrammar = require "../../src/compiler/semantics/values/vds_grammar"
check = require "./check"
FS = require "../../src/compiler/semantics/fs_nodes"

parse = (s, typeStr) ->
  type = VdsGrammar.parse(new Stream(Parser.parse_list_of_component_values(typeStr)))
  type.setFs(new FS.FunctionalStylesheet())
  value = type.parse(s)
  ssjs = value.ssjs()
  eval("#{ssjs}")


check_value = (str, typeStr, next, value) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  t = parse(s, typeStr)
  t.should.equal(value) unless t is undefined and value is undefined
  s.position.should.be.equal(next)

describe "LL ss() of", ->
  describe "keyword", ->
    it "works for ident", ->
      check_value "asdf", "asdf", 1, "asdf"

  describe "<ident>", ->
    it "works for an ident", ->
      check_value "asdf", "<ident>", 1, "asdf"

  describe "<number>", ->
    it "works for a number", ->
      check_value "3.14", "<number>", 1, "3.14"
    it "works for an integer", ->
      check_value "3", "<number>", 1, "3"

  describe "<integer>", ->
    it "works for an integer", ->
      check_value "3", "<integer>", 1, "3"

  describe "delimiters", ->
    it "works for a slash token", ->
      check_value "/", "/", 1, "/"
    it "works for a comma token", ->
      check_value ",", ",", 1, ","

  describe "<percentage>", ->
    it "works for a percentage", ->
      check_value "3%", "<percentage>", 1, "3%"
    it "cannot parse sth", ->

  describe "<string>", ->
    it "works for a string", ->
      check_value "'asdf'", "<string>", 1, '"asdf"'
    it "works for a string with doulbe quotes", ->
      check_value '"asdf"', "<string>", 1, '"asdf"'


  describe "Juxtaposition", ->
    it "works", ->
      check_value "black 3.3", "black <number>", 3, "black 3.3"
    it "works with three elements", ->
      check_value "black 3.3 12%", "black <number> <percentage>", 5, "black 3.3 12%"
      check_value "black 3.3 12%", "[black <number> <percentage>]", 5, "black 3.3 12%"
    it "works with three elements grouped 1-2", ->
      check_value "black 3.3 12%", "[black <number>] <percentage>", 5, "black 3.3 12%"
    it "works with three elements grouped 2-3", ->
      check_value "black 3.3 12%", "black [<number> <percentage>]", 5, "black 3.3 12%"

  describe "double ampersand", ->
    it "works forward", ->
      check_value "black 3.3", "black && <number>", 3, "black 3.3"
    it "works backwards", ->
      check_value "3.3 black", "black && <number>", 3, "black 3.3"

  describe "double bar", ->
    it "works forward", ->
      check_value "black 3.3", "black || <number>", 3, "black 3.3"
    it "works backwards", ->
      check_value "3.3 black", "black || <number>", 3, "black 3.3"
    it "works for first", ->
      check_value "black", "black || <number>", 1, "black"
    it "works for second", ->
      check_value "3.3", "black || <number>", 1, "3.3"

  describe "Bar", ->
    it "works for first", ->
      check_value "black", "black | <number>", 1, "black"
    it "works for second", ->
      check_value "3.3", "black | <number>", 1, "3.3"

  describe "Asterisk", ->
    it "works for none", ->
      check_value "", "<number>*", 0, ""
    it "works for one", ->
      check_value "1", "<number>*", 1, "1"
    it "works for two", ->
      check_value "1 2", "<number>*", 3, "1 2"
    it "works for three", ->
      check_value "1 2 3", "<number>*", 5, "1 2 3"
    it "works for sth", ->
      check_value "black", "<number>*", 0, ""

  describe "Plus", ->
    it "works for one", ->
      check_value "1", "<number>+", 1, "1"
      check_value "1", "[<number>+]", 1, "1"
      check_value "1", "[<number>]+", 1, "1"
    it "works for two", ->
      check_value "1 2", "<number>+", 3, "1 2"
    it "works for three", ->
      check_value "1 2 3", "<number>+", 5, "1 2 3"

  describe "QuestionMark", ->
    it "works for none", ->
      check_value "", "<number>?", 0, ""
    it "works for one", ->
      check_value "3.3", "<number>?", 1, "3.3"
    it "works for two", ->
      check_value "3.3 2", "<number>?", 1, "3.3"
    it "works for sth", ->
      check_value "black", "<number>?", 0, ""

  describe "Range", ->
    it "works for one", ->
      check_value "1", "<number>{1,3}", 1, "1"
    it "works for two", ->
      check_value "1 2", "<number>{1,3}", 3, "1 2"
    it "works for three", ->
      check_value "1 2 3", "<number>{1,3}", 5, "1 2 3"
    it "works for four", ->
      check_value "1 2 3 4", "<number>{1,3}", 6, "1 2 3"

  describe "Hashmark", ->
    it "works for one", ->
      check_value "1", "<number>#", 1, "1"
    it "works for two", ->
      check_value "1, 2", "<number>#", 4, "1, 2"
    it "works for three", ->
      check_value "1, 2,3", "<number>#", 6, "1, 2, 3"


  describe "annotations", ->
    it "works for x:ident", ->
      check_value "black", "color:ident", 1, "black"
    it "works for x:y:ident", ->
      check_value "hello", "x:[y:ident]", 1, "hello"
    it "works for x:[a:[yes] b:[no]]", ->
      check_value "yes no", "x:[a:[yes] b:[no]]", 3, "yes no"
    it "works for x:[a:[yes] && b:[no]]", ->
      check_value "yes no", "x:[a:[yes] && b:[no]]", 3, "yes no"
      check_value "no yes", "x:[a:[yes] && b:[no]]", 3, "yes no"
    describe "works for x:[a:[yes] || b:[no]]", ->
      specify "for 'yes no'", ->
        check_value "yes no", "x:[a:[yes] || b:[no]]", 3, "yes no"
      specify "for 'no yes'", ->
        check_value "no yes", "x:[a:[yes] || b:[no]]", 3, "yes no"
      specify "for 'no'", ->
        check_value "no", "x:[a:[yes] || b:[no]]", 1, "no"
      specify "for 'yes'", ->
        check_value "yes", "x:[a:[yes] || b:[no]]", 1, "yes"
    describe "works for x:[a:[yes] | b:[no]]", ->
      specify "for 'no'", ->
        check_value "no", "x:[a:[yes] | b:[no]]", 1, "no"
      specify "for 'yes'", ->
        check_value "yes", "x:[a:[yes] | b:[no]]", 1, "yes"
    describe "works for x:[a:[yes] | b:[no]]*", ->
      specify "for ''", ->
        check_value "", "x:[a:[yes] | b:[no]]*", 0, ""
      specify "for 'no'", ->
        check_value "no", "x:[a:[yes] | b:[no]]*", 1, "no"
      specify "for 'yes'", ->
        check_value "yes", "x:[a:[yes] | b:[no]]*", 1, "yes"
      specify "for 'no    yes no'", ->
        check_value "no    yes no", "x:[a:[yes] | b:[no]]*", 5, "no yes no"
      specify "for 'no yes/*-*/yes'", ->
        check_value "no yes/*-*/yes", "x:[a:[yes] | b:[no]]*", 4, "no yes yes"
    describe "works for x:[a:[yes] | b:[no]]#", ->
      specify "for 'no'", ->
        check_value "no", "x:[a:[yes] | b:[no]]#", 1, "no"
      specify "for 'yes'", ->
        check_value "yes", "x:[a:[yes] | b:[no]]#", 1, "yes"
      specify "for 'no,    yes, no'", ->
        check_value "no,    yes, no", "x:[a:[yes] | b:[no]]#", 7, "no, yes, no"
      specify "for 'no, yes,yes'", ->
        check_value "no, yes,yes", "x:[a:[yes] | b:[no]]#", 6, "no, yes, yes"

  describe "functional notations", ->
    it "works for f(x)", ->
      check_value "abs(-5)", "abs(<number>)", 1, "abs(-5)"





