Tokenizer = require "../../src/compiler/syntax/tokenizer"
Parser = require "../../src/compiler/syntax/parser"
SS = require "../../src/compiler/syntax/ss_nodes"

check = require "./check"

describe 'Parser', ->
  it "has tree classes", ->
    new SS.SimpleBlock().should.be.instanceOf SS.SimpleBlock

  it "can parse a list of component values", ->
    result = Parser.parse_list_of_component_values("asdf 3.3 bc/2+f(x)")
    check result, SS.ComponentValueList, length: 9
    check result[0], SS.IdentToken, value:"asdf"
    check result[1], SS.WhitespaceToken
    check result[2], SS.NumberToken, value: 3.3, repr: "3.3", type: "number"
    check result[3], SS.WhitespaceToken
    check result[4], SS.IdentToken, value:"bc"
    check result[5], SS.DelimToken, value:"/"
    check result[6], SS.NumberToken, value: 2, repr: "2", type: "integer"
    check result[7], SS.DelimToken, value:"+"
    check result[8], SS.Function, name: "f"
    check result[8].value[0], SS.IdentToken, value: "x"

  it "can parse a component value", ->
    result = Parser.parse_component_value("f(rgb 12!6)  ")
    check result, SS.Function, name: "f"
    check result.value, SS.ComponentValueList, length:5
    check result.value[0], SS.IdentToken, value:"rgb"
    check result.value[1], SS.WhitespaceToken
    check result.value[2], SS.NumberToken, value: 12, repr: "12", type: "integer"
    check result.value[3], SS.DelimToken, value:"!"
    check result.value[4], SS.NumberToken, value: 6, repr: "6", type: "integer"

  it "can parse a bad component value", ->
    result = Parser.parse_component_value("f(rgb 12!6)  a")
    check result, SS.SyntaxError, {}

  it "can parse a qualified rule", ->
    result = Parser.parse_rule(".asdf { efg :   abcde }")
    check result, SS.QualifiedRule
    check result.prelude, SS.ComponentValueList, length: 3
    check result.prelude[0], SS.DelimToken, value:"."
    check result.prelude[1], SS.IdentToken, value:"asdf"
    check result.prelude[2], SS.WhitespaceToken
    check result.value, SS.SimpleBlock
    check result.value.token, SS.OpeningCurlyToken
    result2 = Parser.parse_list_of_declarations(result.value.value)
    check result2, SS.DeclarationList, length: 1
    check result2[0], SS.Declaration, name: "efg"
    check result2[0].value, SS.ComponentValueList, length: 3
    check result2[0].value[0], SS.WhitespaceToken
    check result2[0].value[1], SS.IdentToken, value:"abcde"
    check result2[0].value[2], SS.WhitespaceToken

  it "can parse two qualified rules with two declarations", ->
    result = Parser.parse_list_of_rules(".asdf{efg:abcde;}#cgd  tf>b{basd:2px;urs:3px}")
    check result, SS.RuleList, length:2
    check result[0], SS.QualifiedRule
    check result[0].prelude, SS.ComponentValueList, length: 2
    check result[0].prelude[0], SS.DelimToken, value:"."
    check result[0].prelude[1], SS.IdentToken, value:"asdf"
    check result[0].value, SS.SimpleBlock
    check result[0].value.token, SS.OpeningCurlyToken
    check result[1], SS.QualifiedRule
    check result[1].prelude, SS.ComponentValueList, length: 5
    check result[1].prelude[0], SS.HashToken, value:"cgd", type:"id"
    check result[1].prelude[1], SS.WhitespaceToken
    check result[1].prelude[2], SS.IdentToken, value:"tf"
    check result[1].prelude[3], SS.DelimToken, value:">"
    check result[1].prelude[4], SS.IdentToken, value:"b"
    check result[1].value, SS.SimpleBlock
    check result[1].value.token, SS.OpeningCurlyToken
    result2 = Parser.parse_list_of_declarations(result[0].value.value)
    check result2, SS.DeclarationList, length: 1
    check result2[0], SS.Declaration, name: "efg"
    check result2[0].value, SS.ComponentValueList, length: 1
    check result2[0].value[0], SS.IdentToken, value:"abcde"
    result3 = Parser.parse_list_of_declarations(result[1].value.value)
    check result3, SS.DeclarationList, length: 2
    check result3[0], SS.Declaration, name: "basd"
    check result3[0].value, SS.ComponentValueList, length: 1
    check result3[0].value[0], SS.DimensionToken, value:2, unit:"px", repr:"2", type:"integer"
    check result3[1], SS.Declaration, name: "urs"
    check result3[1].value, SS.ComponentValueList, length: 1
    check result3[1].value[0], SS.DimensionToken, value:3, unit:"px", repr:"3", type:"integer"

  it "can parse a SS.stylesheet", ->
    result = Parser.parse_stylesheet(".asdf{efg:abcde;}#cgd  tf>b{basd:2px;urs:3px}")
    check result, SS.Stylesheet
    check result.value, SS.RuleList, length:2
    check result.value[0], SS.QualifiedRule
    check result.value[0].prelude, SS.ComponentValueList, length: 2
    check result.value[0].prelude[0], SS.DelimToken, value:"."
    check result.value[0].prelude[1], SS.IdentToken, value:"asdf"
    check result.value[0].value, SS.SimpleBlock
    check result.value[0].value.token, SS.OpeningCurlyToken
    check result.value[1], SS.QualifiedRule
    check result.value[1].prelude, SS.ComponentValueList, length: 5
    check result.value[1].prelude[0], SS.HashToken, value:"cgd", type:"id"
    check result.value[1].prelude[1], SS.WhitespaceToken
    check result.value[1].prelude[2], SS.IdentToken, value:"tf"
    check result.value[1].prelude[3], SS.DelimToken, value:">"
    check result.value[1].prelude[4], SS.IdentToken, value:"b"
    check result.value[1].value, SS.SimpleBlock
    check result.value[1].value.token, SS.OpeningCurlyToken
    result2 = Parser.parse_list_of_declarations(result.value[0].value.value)
    check result2, SS.DeclarationList, length: 1
    check result2[0], SS.Declaration, name: "efg"
    check result2[0].value, SS.ComponentValueList, length: 1
    check result2[0].value[0], SS.IdentToken, value:"abcde"
    result3 = Parser.parse_list_of_declarations(result.value[1].value.value)
    check result3, SS.DeclarationList, length: 2
    check result3[0], SS.Declaration, name: "basd"
    check result3[0].value, SS.ComponentValueList, length: 1
    check result3[0].value[0], SS.DimensionToken, value:2, unit:"px", repr:"2", type:"integer"
    check result3[1], SS.Declaration, name: "urs"
    check result3[1].value, SS.ComponentValueList, length: 1
    check result3[1].value[0], SS.DimensionToken, value:3, unit:"px", repr:"3", type:"integer"


  it "can parse an at-rule", ->
    result = Parser.parse_rule("@asdf { efg :   abcde;@ab{8} }")
    check result, SS.AtRule, name: "asdf"
    check result.prelude, SS.ComponentValueList, length: 1
    check result.prelude[0], SS.WhitespaceToken
    check result.value, SS.SimpleBlock
    check result.value.token, SS.OpeningCurlyToken
    check result.value.value, SS.ComponentValueList, length:10
    check result.value.value[0], SS.WhitespaceToken
    check result.value.value[1], SS.IdentToken, value:"efg"
    check result.value.value[2], SS.WhitespaceToken
    check result.value.value[3], SS.ColonToken
    check result.value.value[4], SS.WhitespaceToken
    check result.value.value[5], SS.IdentToken, value:"abcde"
    check result.value.value[6], SS.SemicolonToken
    check result.value.value[7], SS.AtKeywordToken, value:"ab"
    check result.value.value[8], SS.SimpleBlock
    check result.value.value[8].token, SS.OpeningCurlyToken
    check result.value.value[8].value, SS.ComponentValueList, length:1
    check result.value.value[8].value[0], SS.NumberToken, value: 8, repr: "8", type:"integer"
    check result.value.value[9], SS.WhitespaceToken
    result2 = Parser.parse_list_of_declarations(result.value.value)
    check result2, SS.DeclarationList, length: 2
    check result2[0], SS.Declaration, name:"efg"
    check result2[0].value, SS.ComponentValueList, length: 2
    check result2[0].value[0], SS.WhitespaceToken
    check result2[0].value[1], SS.IdentToken, value:"abcde"
    check result2[1], SS.AtRule, name:"ab"
    check result2[1].prelude, SS.ComponentValueList, length:0
    check result2[1].value, SS.SimpleBlock
    check result2[1].value.token, SS.OpeningCurlyToken
    check result2[1].value.value, SS.ComponentValueList, length:1
    check result2[1].value.value[0], SS.NumberToken, value: 8, repr: "8", type:"integer"
    





