Types = require "#{__dirname}/../../src/compiler/types"
Stream = require "#{__dirname}/../../src/compiler/stream"
Parser = require "#{__dirname}/../../src/compiler/parser"
Tokenizer = require "#{__dirname}/../../src/compiler/tokenizer"
check = require "#{__dirname}/../check"

tree = (str, type) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  type(s)

describe 'Types', ->
  describe 'IdentType', ->
    asdf = Types.IdentType("asdf")((x)->x)

    it "can parse ident", ->
      check tree("asdf", asdf), Tokenizer.IdentToken, value: "asdf"

    it "can parse $x:ident", ->
      result = Types.IdentType("asdf")((x)->{x:x})(new Stream(Parser.parse_list_of_component_values("asdf")))
      check result, Object
      check result.x, Tokenizer.IdentToken, value: "asdf"

  describe 'Number', ->
    number =  Types.Number((x)->x)
    it "can parse 3", ->
      check tree("3", number), Tokenizer.NumberToken, value: 3, type: "integer"
    it "can parse 3.0", ->
      check tree("3.0", number), Tokenizer.NumberToken, value: 3, type: "number"
    it "cannot parse 'str'", ->
      check.error Types.NoMatch, message: "number expected but '\"str\"' found", ->
        tree("'str'", number)

  describe 'Integer', ->
    integer = Types.Integer((x)->x)

    it "can parse 3", ->
      check tree("3", integer), Tokenizer.NumberToken, value: 3, type:"integer"

    it "cannot parse 3.3", ->
      check.error Types.NoMatch, message: "integer expected but '3.3' found", ->
        tree("3.3", integer)

  describe 'Juxtaposition', ->
    jp = Types.Juxtaposition(Types.IdentType('black')((x)->x.value), Types.Number((x)->x.value))((x,y)->{x,y})
    
    it "works", ->
      check tree("black 3.3", jp), Object, x:"black", y:3.3
    it "fails for first bad type", ->
      check.error Types.NoMatch, message: "'black' expected but 'green' found", ->
        tree("green 3.3", jp)
    it "fails for first EOF", ->
      check.error Types.NoMatch, message: "'black' expected but '' found", ->
        tree("", jp)
    it "fails for second EOF", ->
      check.error Types.NoMatch, message: "number expected but '' found", ->
        tree("black", jp)
    it "fails for second _EOF", ->
      check.error Types.NoMatch, message: "number expected but '' found", ->
        tree("black    ", jp)
    it "fails for second bad type", ->
      check.error Types.NoMatch, message: "number expected but 'green' found", ->
        tree("black green", jp)

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
      t3 = Types.DoubleBar(
          Types.IdentType("hello")(->hello:true),
          Types.DoubleBar(
            Types.Number((x)->number:x.value),
            Types.IdentType("world")(->world:true)
          )((x,y)->number:x.number,world:y.world)
        )((x,y)->hello:x?.hello,number:y?.number,world:y?.world)

      ###
      it "can parse first second third", ->
        check tree("hello 3.3 world", t3), Object, hello:true, number:3.3, world:true
      it "can parse first third", ->
        check tree("hello world", t3), Object, hello:true, number:undefined, world:true
      it "can parse first second", ->
        check tree("hello 3.3", t3), Object, hello:true, number:3.3, world:undefined
      it "can parse first_", ->
        check tree("hello ", t3), Object, hello:true, number:undefined, world:undefined
      it "can parse first", ->
        check tree("hello", t3), Object, hello:true, number:undefined, world:undefined
      ###

    it "can fail for invalid", ->
      err = undefined
      try
        result = Types.DoubleBar(Types.Ident((x)->x),
          Types.Number((x)->x))((x,y)->{x:x?.value,y:y?.value})(new Stream(Parser.parse_list_of_component_values("2px")))
      catch e
        err = e
      check err, Types.NoMatch, message:"identifier or number expected but '2px' found"




    
