Types = require "#{__dirname}/../../src/compiler/types"
Stream = require "#{__dirname}/../../src/compiler/stream"
Parser = require "#{__dirname}/../../src/compiler/parser"
Tokenizer = require "#{__dirname}/../../src/compiler/tokenizer"
check = require "#{__dirname}/../check"

describe 'Types', ->
  it "can parse ident", ->
    result = Types.IdentType("asdf")((x)->x)(new Stream(Parser.parse_list_of_component_values("asdf")))
    check result, Tokenizer.IdentToken, value: "asdf"
  it "can parse $x:ident", ->
    result = Types.IdentType("asdf")((x)->{x:x})(new Stream(Parser.parse_list_of_component_values("asdf")))
    check result, Object
    check result.x, Tokenizer.IdentToken, value: "asdf"
  it "can parse 3", ->
    result = Types.Number((x)->x)(new Stream(Parser.parse_list_of_component_values("3")))
    check result, Tokenizer.NumberToken, value: 3
    result = Types.Integer((x)->x)(new Stream(Parser.parse_list_of_component_values("3")))
    check result, Tokenizer.NumberToken, value: 3
  it "can parse 3.3", ->
    result = Types.Number((x)->x)(new Stream(Parser.parse_list_of_component_values("3.3")))
    check result, Tokenizer.NumberToken, value: 3.3
    error = null
    try
      result = Types.Integer((x)->x)(new Stream(Parser.parse_list_of_component_values("3.3")))
    catch e
      error = e
    check error, Types.NoMatch, message: "expected integer but 3.3 found"
  it "can give parse errors", ->
    try
      result = Types.Number((x)->x)(new Stream(Parser.parse_list_of_component_values("'str'")))
    catch e
      error = e
    check error, Types.NoMatch, message: "expected number but '\"str\"' found"
  it "can parse juxtaposition", ->
    result = Types.Juxtaposition(Types.IdentType("black")((x)->x), Types.Number((x)->x))((x,y)->[x,y])(new Stream(Parser.parse_list_of_component_values("black 3.3")))
    check result, Array, length: 2
    check result[0], Tokenizer.IdentToken, value: "black"
    check result[1], Tokenizer.NumberToken, value: 3.3
  it "can parse double ampersand", ->
    result = Types.DoubleAmpersand(Types.Ident((x)->x),
      Types.Number((x)->x))((x,y)->[x,y])(new Stream(Parser.parse_list_of_component_values("black 3.3")))
    check result, Array, length: 2
    check result[0], Tokenizer.IdentToken, value: "black"
    check result[1], Tokenizer.NumberToken, value: 3.3
    result = Types.DoubleAmpersand(Types.Ident((x)->x),
      Types.Number((x)->x))((x,y)->[x,y])(new Stream(Parser.parse_list_of_component_values("3.3 black")))
    check result, Array, length: 2
    check result[0], Tokenizer.IdentToken, value: "black"
    check result[1], Tokenizer.NumberToken, value: 3.3
    
  it "can parse bar", ->
    result = Types.Bar(Types.Ident((x)->x),
      Types.Number((x)->x))((x,y)->x || y)(new Stream(Parser.parse_list_of_component_values("black")))
    check result, Tokenizer.IdentToken, value: "black"
    result = Types.Bar(Types.Ident((x)->x),
      Types.Number((x)->x))((x,y)->x || y)(new Stream(Parser.parse_list_of_component_values("3.3")))
    check result, Tokenizer.NumberToken, value: 3.3



    
