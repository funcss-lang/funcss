GR = require "../../src/compiler/semantics/../syntax/gr_nodes"
DF = require "../../src/compiler/semantics/definitions/df_nodes"
DefGrammar = require "../../src/compiler/semantics/definitions/def_grammar"
Parser = require "../../src/compiler/syntax/parser"
Tokenizer = require "../../src/compiler/syntax/tokenizer"
SS = require "../../src/compiler/syntax/ss_nodes"
check = require "./check"

check_tree = (str, args...) ->
  t = DefGrammar.parse(str)
  check t, args...
  t

describe "DefGrammar", ->
  it "can parse a variable definition", ->
    t = check_tree "x:number = 9", DF.Definition, typeName: "number"
    check t.definable, DF.VariableName, value: "x"
    check t.rawValue, SS.ComponentValueList, length: 1
    check t.rawValue[0], SS.NumberToken, value: 9, type: "integer"

  it "can parse a variable definition witout type", ->
    t = check_tree "x = 9", DF.Definition, typeName: undefined
    check t.definable, DF.VariableName, value: "x"
    check t.rawValue, SS.ComponentValueList, length: 1
    check t.rawValue[0], SS.NumberToken, value: 9, type: "integer"

  it "can parse a function definition", ->
    t = check_tree "x():number = 9", DF.Definition, typeName: "number"
    check t.definable, DF.FunctionalNotation, name: "x"
    check t.definable.argument, GR.Empty
    check t.rawValue, SS.ComponentValueList, length: 1
    check t.rawValue[0], SS.NumberToken, value: 9, type: "integer"

  it "can parse a function definition witout type", ->
    t = check_tree "x() = 9", DF.Definition, typeName: undefined
    check t.definable, DF.FunctionalNotation, name: "x"
    check t.definable.argument, GR.Empty
    check t.rawValue, SS.ComponentValueList, length: 1
    check t.rawValue[0], SS.NumberToken, value: 9, type: "integer"
