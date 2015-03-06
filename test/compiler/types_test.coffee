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
    check error, Types.NoMatch, message: "integer expected but 3.3 found"
  it "can give parse errors", ->
    try
      result = Types.Number((x)->x)(new Stream(Parser.parse_list_of_component_values("'str'")))
    catch e
      error = e
    check error, Types.NoMatch, message: "number expected but '\"str\"' found"
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

  describe 'DoubleBar', ->
    it "can parse first branch", ->
      result = Types.DoubleBar(Types.Ident((x)->x),
        Types.Number((x)->x))((x,y)->{x:x?.value,y:y?.value})(new Stream(Parser.parse_list_of_component_values("black")))
      check result, Object, x:"black", y:undefined

    it "can parse the second branch", ->
      result = Types.DoubleBar(Types.Ident((x)->x),
        Types.Number((x)->x))((x,y)->{x:x?.value,y:y?.value})(new Stream(Parser.parse_list_of_component_values("3.3")))
      check result, Object, x:undefined, y:3.3

    it "can parse first second", ->
      result = Types.DoubleBar(Types.Ident((x)->x),
        Types.Number((x)->x))((x,y)->{x:x?.value,y:y?.value})(new Stream(Parser.parse_list_of_component_values("black 3.3")))
      check result, Object, x:"black", y:3.3

    it "can parse second first", ->
      result = Types.DoubleBar(Types.Ident((x)->x),
        Types.Number((x)->x))((x,y)->{x:x?.value,y:y?.value})(new Stream(Parser.parse_list_of_component_values("3.3 black")))
      check result, Object, x:"black", y:3.3

    it "can parse first/**/second", ->
      result = Types.DoubleBar(Types.Ident((x)->x),
        Types.Number((x)->x))((x,y)->{x:x?.value,y:y?.value})(new Stream(Parser.parse_list_of_component_values("black/**/3.3")))
      check result, Object, x:"black", y:3.3

    it "can parse second/**/first", ->
      result = Types.DoubleBar(Types.Ident((x)->x),
        Types.Number((x)->x))((x,y)->{x:x?.value,y:y?.value})(new Stream(Parser.parse_list_of_component_values("3.3/**/black")))
      check result, Object, x:"black", y:3.3

    describe "for three arguments", ->
      it "can parse first second third", ->
        s = new Stream(Parser.parse_list_of_component_values("hello 3.3 world"))
        result = Types.DoubleBar(
          Types.IdentType("hello")(->hello:true),
          Types.DoubleBar(
            Types.Number((x)->number:x.value),
            Types.IdentType("world")(->world:true)
          )((x,y)->number:x.number,world:y.world)
        )((x,y)->hello:x?.hello,number:y?.number,world:y?.world)(s)
        check result, Object, hello:true, number:3.3, world:true

    it "can fail for invalid", ->
      err = undefined
      try
        result = Types.DoubleBar(Types.Ident((x)->x),
          Types.Number((x)->x))((x,y)->{x:x?.value,y:y?.value})(new Stream(Parser.parse_list_of_component_values("2px")))
      catch e
        err = e
      check err, Types.NoMatch, message:"identifier or number expected but '2px' found"




    
