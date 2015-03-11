Tokenizer = require("#{__dirname}/../../src/compiler/tokenizer.coffee")
Parser = require("#{__dirname}/../../src/compiler/parser.coffee")
N = require "../../src/compiler/nodes"

check = require "#{__dirname}/../check"

describe 'Parser', ->
  it "has tree classes", ->
    new N.SimpleBlock().should.be.instanceOf N.SimpleBlock

  it "can parse a list of component values", ->
    result = Parser.parse_list_of_component_values("asdf 3.3 bc/2+f(x)")
    check result, N.ComponentValueList, length: 9
    check result[0], N.IdentToken, value:"asdf"
    check result[1], N.WhitespaceToken
    check result[2], N.NumberToken, value: 3.3, repr: "3.3", type: "number"
    check result[3], N.WhitespaceToken
    check result[4], N.IdentToken, value:"bc"
    check result[5], N.DelimToken, value:"/"
    check result[6], N.NumberToken, value: 2, repr: "2", type: "integer"
    check result[7], N.DelimToken, value:"+"
    check result[8], N.Function, name: "f"
    check result[8].value[0], N.IdentToken, value: "x"

  it "can parse a component value", ->
    result = Parser.parse_component_value("f(rgb 12!6)  ")
    check result, N.Function, name: "f"
    check result.value, N.ComponentValueList, length:5
    check result.value[0], N.IdentToken, value:"rgb"
    check result.value[1], N.WhitespaceToken
    check result.value[2], N.NumberToken, value: 12, repr: "12", type: "integer"
    check result.value[3], N.DelimToken, value:"!"
    check result.value[4], N.NumberToken, value: 6, repr: "6", type: "integer"

  it "can parse a bad component value", ->
    result = Parser.parse_component_value("f(rgb 12!6)  a")
    check result, N.SyntaxError, {}

  it "can parse a qualified rule", ->
    result = Parser.parse_rule(".asdf { efg :   abcde }")
    check result, N.QualifiedRule
    check result.prelude, N.ComponentValueList, length: 3
    check result.prelude[0], N.DelimToken, value:"."
    check result.prelude[1], N.IdentToken, value:"asdf"
    check result.prelude[2], N.WhitespaceToken
    check result.value, N.SimpleBlock
    check result.value.token, N.OpeningCurlyToken
    result2 = Parser.parse_list_of_declarations(result.value.value)
    check result2, N.DeclarationList, length: 1
    check result2[0], N.Declaration, name: "efg"
    check result2[0].value, N.ComponentValueList, length: 3
    check result2[0].value[0], N.WhitespaceToken
    check result2[0].value[1], N.IdentToken, value:"abcde"
    check result2[0].value[2], N.WhitespaceToken

  it "can parse two qualified rules with two declarations", ->
    result = Parser.parse_list_of_rules(".asdf{efg:abcde;}#cgd  tf>b{basd:2px;urs:3px}")
    check result, N.RuleList, length:2
    check result[0], N.QualifiedRule
    check result[0].prelude, N.ComponentValueList, length: 2
    check result[0].prelude[0], N.DelimToken, value:"."
    check result[0].prelude[1], N.IdentToken, value:"asdf"
    check result[0].value, N.SimpleBlock
    check result[0].value.token, N.OpeningCurlyToken
    check result[1], N.QualifiedRule
    check result[1].prelude, N.ComponentValueList, length: 5
    check result[1].prelude[0], N.HashToken, value:"cgd", type:"id"
    check result[1].prelude[1], N.WhitespaceToken
    check result[1].prelude[2], N.IdentToken, value:"tf"
    check result[1].prelude[3], N.DelimToken, value:">"
    check result[1].prelude[4], N.IdentToken, value:"b"
    check result[1].value, N.SimpleBlock
    check result[1].value.token, N.OpeningCurlyToken
    result2 = Parser.parse_list_of_declarations(result[0].value.value)
    check result2, N.DeclarationList, length: 1
    check result2[0], N.Declaration, name: "efg"
    check result2[0].value, N.ComponentValueList, length: 1
    check result2[0].value[0], N.IdentToken, value:"abcde"
    result3 = Parser.parse_list_of_declarations(result[1].value.value)
    check result3, N.DeclarationList, length: 2
    check result3[0], N.Declaration, name: "basd"
    check result3[0].value, N.ComponentValueList, length: 1
    check result3[0].value[0], N.DimensionToken, value:2, unit:"px", repr:"2", type:"integer"
    check result3[1], N.Declaration, name: "urs"
    check result3[1].value, N.ComponentValueList, length: 1
    check result3[1].value[0], N.DimensionToken, value:3, unit:"px", repr:"3", type:"integer"

  it "can parse a N.stylesheet", ->
    result = Parser.parse_stylesheet(".asdf{efg:abcde;}#cgd  tf>b{basd:2px;urs:3px}")
    check result, N.Stylesheet
    check result.value, N.RuleList, length:2
    check result.value[0], N.QualifiedRule
    check result.value[0].prelude, N.ComponentValueList, length: 2
    check result.value[0].prelude[0], N.DelimToken, value:"."
    check result.value[0].prelude[1], N.IdentToken, value:"asdf"
    check result.value[0].value, N.SimpleBlock
    check result.value[0].value.token, N.OpeningCurlyToken
    check result.value[1], N.QualifiedRule
    check result.value[1].prelude, N.ComponentValueList, length: 5
    check result.value[1].prelude[0], N.HashToken, value:"cgd", type:"id"
    check result.value[1].prelude[1], N.WhitespaceToken
    check result.value[1].prelude[2], N.IdentToken, value:"tf"
    check result.value[1].prelude[3], N.DelimToken, value:">"
    check result.value[1].prelude[4], N.IdentToken, value:"b"
    check result.value[1].value, N.SimpleBlock
    check result.value[1].value.token, N.OpeningCurlyToken
    result2 = Parser.parse_list_of_declarations(result.value[0].value.value)
    check result2, N.DeclarationList, length: 1
    check result2[0], N.Declaration, name: "efg"
    check result2[0].value, N.ComponentValueList, length: 1
    check result2[0].value[0], N.IdentToken, value:"abcde"
    result3 = Parser.parse_list_of_declarations(result.value[1].value.value)
    check result3, N.DeclarationList, length: 2
    check result3[0], N.Declaration, name: "basd"
    check result3[0].value, N.ComponentValueList, length: 1
    check result3[0].value[0], N.DimensionToken, value:2, unit:"px", repr:"2", type:"integer"
    check result3[1], N.Declaration, name: "urs"
    check result3[1].value, N.ComponentValueList, length: 1
    check result3[1].value[0], N.DimensionToken, value:3, unit:"px", repr:"3", type:"integer"


  it "can parse an at-rule", ->
    result = Parser.parse_rule("@asdf { efg :   abcde;@ab{8} }")
    check result, N.AtRule, name: "asdf"
    check result.prelude, N.ComponentValueList, length: 1
    check result.prelude[0], N.WhitespaceToken
    check result.value, N.SimpleBlock
    check result.value.token, N.OpeningCurlyToken
    check result.value.value, N.ComponentValueList, length:10
    check result.value.value[0], N.WhitespaceToken
    check result.value.value[1], N.IdentToken, value:"efg"
    check result.value.value[2], N.WhitespaceToken
    check result.value.value[3], N.ColonToken
    check result.value.value[4], N.WhitespaceToken
    check result.value.value[5], N.IdentToken, value:"abcde"
    check result.value.value[6], N.SemicolonToken
    check result.value.value[7], N.AtKeywordToken, value:"ab"
    check result.value.value[8], N.SimpleBlock
    check result.value.value[8].token, N.OpeningCurlyToken
    check result.value.value[8].value, N.ComponentValueList, length:1
    check result.value.value[8].value[0], N.NumberToken, value: 8, repr: "8", type:"integer"
    check result.value.value[9], N.WhitespaceToken
    result2 = Parser.parse_list_of_declarations(result.value.value)
    check result2, N.DeclarationList, length: 2
    check result2[0], N.Declaration, name:"efg"
    check result2[0].value, N.ComponentValueList, length: 2
    check result2[0].value[0], N.WhitespaceToken
    check result2[0].value[1], N.IdentToken, value:"abcde"
    check result2[1], N.AtRule, name:"ab"
    check result2[1].prelude, N.ComponentValueList, length:0
    check result2[1].value, N.SimpleBlock
    check result2[1].value.token, N.OpeningCurlyToken
    check result2[1].value.value, N.ComponentValueList, length:1
    check result2[1].value.value[0], N.NumberToken, value: 8, repr: "8", type:"integer"
    





