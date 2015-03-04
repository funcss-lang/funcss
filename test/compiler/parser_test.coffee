Tokenizer = require("#{__dirname}/../../src/compiler/tokenizer.coffee")
{
  IdentToken
  FunctionToken
  AtKeywordToken
  HashToken
  StringToken
  BadStringToken
  UrlToken
  BadUrlToken
  DelimToken
  NumberToken
  PercentageToken
  DimensionToken
  UnicodeRangeToken
  IncludeMatchToken
  DashMatchToken
  PrefixMatchToken
  SuffixMatchToken
  SubstringMatchToken
  ColumnToken
  WhitespaceToken
  CDOToken
  CDCToken
  ColonToken
  SemicolonToken
  CommaToken
  OpeningSquareToken
  ClosingSquareToken
  OpeningParenToken
  ClosingParenToken
  OpeningCurlyToken
  ClosingCurlyToken
} = Tokenizer

Parser = require("#{__dirname}/../../src/compiler/parser.coffee")
{
  AtRule
  QualifiedRule
  Declaration
  Function
  SimpleBlock
  SyntaxError
  Stylesheet
} = Parser

check = require "#{__dirname}/../check"

describe 'Parser', ->
  it "has tree classes", ->
    new SimpleBlock().should.be.instanceOf SimpleBlock

  it "can parse a list of component values", ->
    result = Parser.parse_list_of_component_values("asdf 3.3 bc/2+f(x)")
    check result, Array, length: 9
    check result[0], IdentToken, value:"asdf"
    check result[1], WhitespaceToken
    check result[2], NumberToken, value: 3.3, repr: "3.3", type: "number"
    check result[3], WhitespaceToken
    check result[4], IdentToken, value:"bc"
    check result[5], DelimToken, value:"/"
    check result[6], NumberToken, value: 2, repr: "2", type: "integer"
    check result[7], DelimToken, value:"+"
    check result[8], Function, name: "f"
    check result[8].value[0], IdentToken, value: "x"

  it "can parse a component value", ->
    result = Parser.parse_component_value("f(rgb 12!6)  ")
    check result, Function, name: "f"
    check result.value, Array, length:5
    check result.value[0], IdentToken, value:"rgb"
    check result.value[1], WhitespaceToken
    check result.value[2], NumberToken, value: 12, repr: "12", type: "integer"
    check result.value[3], DelimToken, value:"!"
    check result.value[4], NumberToken, value: 6, repr: "6", type: "integer"

  it "can parse a bad component value", ->
    result = Parser.parse_component_value("f(rgb 12!6)  a")
    check result, SyntaxError, {}

  it "can parse a qualified rule", ->
    result = Parser.parse_rule(".asdf { efg :   abcde }")
    check result, QualifiedRule
    check result.prelude, Array, length: 3
    check result.prelude[0], DelimToken, value:"."
    check result.prelude[1], IdentToken, value:"asdf"
    check result.prelude[2], WhitespaceToken
    check result.value, SimpleBlock
    check result.value.token, OpeningCurlyToken
    result2 = Parser.parse_list_of_declarations(result.value.value)
    check result2, Array, length: 1
    check result2[0], Declaration, name: "efg"
    check result2[0].value, Array, length: 3
    check result2[0].value[0], WhitespaceToken
    check result2[0].value[1], IdentToken, value:"abcde"
    check result2[0].value[2], WhitespaceToken

  it "can parse two qualified rules with two declarations", ->
    result = Parser.parse_list_of_rules(".asdf{efg:abcde;}#cgd  tf>b{basd:2px;urs:3px}")
    check result, Array, length:2
    check result[0], QualifiedRule
    check result[0].prelude, Array, length: 2
    check result[0].prelude[0], DelimToken, value:"."
    check result[0].prelude[1], IdentToken, value:"asdf"
    check result[0].value, SimpleBlock
    check result[0].value.token, OpeningCurlyToken
    check result[1], QualifiedRule
    check result[1].prelude, Array, length: 5
    check result[1].prelude[0], HashToken, value:"cgd", type:"id"
    check result[1].prelude[1], WhitespaceToken
    check result[1].prelude[2], IdentToken, value:"tf"
    check result[1].prelude[3], DelimToken, value:">"
    check result[1].prelude[4], IdentToken, value:"b"
    check result[1].value, SimpleBlock
    check result[1].value.token, OpeningCurlyToken
    result2 = Parser.parse_list_of_declarations(result[0].value.value)
    check result2, Array, length: 1
    check result2[0], Declaration, name: "efg"
    check result2[0].value, Array, length: 1
    check result2[0].value[0], IdentToken, value:"abcde"
    result3 = Parser.parse_list_of_declarations(result[1].value.value)
    check result3, Array, length: 2
    check result3[0], Declaration, name: "basd"
    check result3[0].value, Array, length: 1
    check result3[0].value[0], DimensionToken, value:2, unit:"px", repr:"2", type:"integer"
    check result3[1], Declaration, name: "urs"
    check result3[1].value, Array, length: 1
    check result3[1].value[0], DimensionToken, value:3, unit:"px", repr:"3", type:"integer"

  it "can parse a stylesheet", ->
    result = Parser.parse_stylesheet(".asdf{efg:abcde;}#cgd  tf>b{basd:2px;urs:3px}")
    check result, Stylesheet
    check result.value, Array, length:2
    check result.value[0], QualifiedRule
    check result.value[0].prelude, Array, length: 2
    check result.value[0].prelude[0], DelimToken, value:"."
    check result.value[0].prelude[1], IdentToken, value:"asdf"
    check result.value[0].value, SimpleBlock
    check result.value[0].value.token, OpeningCurlyToken
    check result.value[1], QualifiedRule
    check result.value[1].prelude, Array, length: 5
    check result.value[1].prelude[0], HashToken, value:"cgd", type:"id"
    check result.value[1].prelude[1], WhitespaceToken
    check result.value[1].prelude[2], IdentToken, value:"tf"
    check result.value[1].prelude[3], DelimToken, value:">"
    check result.value[1].prelude[4], IdentToken, value:"b"
    check result.value[1].value, SimpleBlock
    check result.value[1].value.token, OpeningCurlyToken
    result2 = Parser.parse_list_of_declarations(result.value[0].value.value)
    check result2, Array, length: 1
    check result2[0], Declaration, name: "efg"
    check result2[0].value, Array, length: 1
    check result2[0].value[0], IdentToken, value:"abcde"
    result3 = Parser.parse_list_of_declarations(result.value[1].value.value)
    check result3, Array, length: 2
    check result3[0], Declaration, name: "basd"
    check result3[0].value, Array, length: 1
    check result3[0].value[0], DimensionToken, value:2, unit:"px", repr:"2", type:"integer"
    check result3[1], Declaration, name: "urs"
    check result3[1].value, Array, length: 1
    check result3[1].value[0], DimensionToken, value:3, unit:"px", repr:"3", type:"integer"


  it "can parse an at-rule", ->
    result = Parser.parse_rule("@asdf { efg :   abcde;@ab{8} }")
    check result, AtRule, name: "asdf"
    check result.prelude, Array, length: 1
    check result.prelude[0], WhitespaceToken
    check result.value, SimpleBlock
    check result.value.token, OpeningCurlyToken
    check result.value.value, Array, length:10
    check result.value.value[0], WhitespaceToken
    check result.value.value[1], IdentToken, value:"efg"
    check result.value.value[2], WhitespaceToken
    check result.value.value[3], ColonToken
    check result.value.value[4], WhitespaceToken
    check result.value.value[5], IdentToken, value:"abcde"
    check result.value.value[6], SemicolonToken
    check result.value.value[7], AtKeywordToken, value:"ab"
    check result.value.value[8], SimpleBlock
    check result.value.value[8].token, OpeningCurlyToken
    check result.value.value[8].value, Array, length:1
    check result.value.value[8].value[0], NumberToken, value: 8, repr: "8", type:"integer"
    check result.value.value[9], WhitespaceToken
    result2 = Parser.parse_list_of_declarations(result.value.value)
    check result2, Array, length: 2
    check result2[0], Declaration, name:"efg"
    check result2[0].value, Array, length: 2
    check result2[0].value[0], WhitespaceToken
    check result2[0].value[1], IdentToken, value:"abcde"
    check result2[1], AtRule, name:"ab"
    check result2[1].prelude, Array, length:0
    check result2[1].value, SimpleBlock
    check result2[1].value.token, OpeningCurlyToken
    check result2[1].value.value, Array, length:1
    check result2[1].value.value[0], NumberToken, value: 8, repr: "8", type:"integer"
    







