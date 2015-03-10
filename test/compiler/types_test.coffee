Types = require "#{__dirname}/../../src/compiler/types"
Stream = require "#{__dirname}/../../src/compiler/stream"
Parser = require "#{__dirname}/../../src/compiler/parser"
Tokenizer = require "#{__dirname}/../../src/compiler/tokenizer"
check = require "#{__dirname}/../check"


check_tree = (str, type, next, args...) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  t = type(s)
  check t, args...
  (s.position+1).should.be.equal(next)

check_error = (str, type, pos, message) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  check.error Types.NoMatch, message: message, ->
    t = type(s)
  (s.position+1).should.be.equal(pos)

Value = (x)->x.value
Id = (x)->x

describe 'Types', ->
  describe 'IdentType', ->
    asdf = Types.IdentType("asdf")((x)->x)

    it "can parse ident", ->
      check_tree "asdf", asdf, 1, Tokenizer.IdentToken, value: "asdf"

    it "can parse $x:ident", ->
      result = Types.IdentType("asdf")((x)->{x:x})(new Stream(Parser.parse_list_of_component_values("asdf")))
      check result, Object
      check result.x, Tokenizer.IdentToken, value: "asdf"

  describe 'Number', ->
    number =  Types.Number((x)->x)
    it "can parse 3", ->
      check_tree "3", number, 1, Tokenizer.NumberToken, value: 3, type: "integer"
    it "can parse 3.0", ->
      check_tree "3.0", number, 1, Tokenizer.NumberToken, value: 3, type: "number"
    it "cannot parse 'str'", ->
      check_error "'str'", number, 0, "number expected but '\"str\"' found"

  describe 'Integer', ->
    integer = Types.Integer((x)->x)

    it "can parse 3", ->
      check_tree "3", integer, 1, Tokenizer.NumberToken, value: 3, type:"integer"

    it "cannot parse 3.3", ->
      check_error "3.3", integer, 0, "integer expected but '3.3' found"

  describe 'Juxtaposition', ->
    jp = Types.Juxtaposition(Types.IdentType('black')(Value), Types.Number(Value))((x,y)->{x,y})
    
    it "works", ->
      check_tree "black 3.3", jp, 3, Object, x:"black", y:3.3
    it "fails for first bad type", ->
      check_error "green 3.3", jp, 0, "'black' expected but 'green' found", ->
    it "fails for first EOF", ->
      check_error "", jp, 0, "'black' expected but '' found"
    it "fails for second EOF", ->
      check_error "black", jp, 1, "number expected but '' found"
    it "fails for second _EOF", ->
      check_error "black    ", jp, 2, "number expected but '' found"
    it "fails for second bad type", ->
      check_error "black green", jp, 2, "number expected but 'green' found"

  describe "DoubleAmpersand", ->
    da = Types.DoubleAmpersand(Types.Ident(Value),Types.Number(Value))((x,y)->{x,y})
    
    it "can parse first second", ->
      check_tree "black 3.3", da, 3, Object, x:"black", y:3.3
    it "can parse second first", ->
      check_tree "3.3 black", da, 3, Object, x:"black", y:3.3
    
  describe "Bar", ->
    bar = Types.Bar(Types.Ident(Value), Types.Number(Value))((x)->{value: x})

    it "can parse first", ->
      check_tree "black", bar, 1, Object, value: "black"

    it "can parse second", ->
      check_tree "3.3", bar, 1, Object, value: 3.3

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
          )((x,y)->number:x?.number,world:y?.world)
        )((x,y)->hello:x?.hello,number:y?.number,world:y?.world)

      it "can parse first second third", ->
        check_tree "hello 3.3 world", t3, 5, Object, hello:true, number:3.3, world:true
      it "can parse first third", ->
        check_tree "hello world", t3, 3, Object, hello:true, number:undefined, world:true
      it "can parse first second", ->
        check_tree "hello 3.3", t3, 3, Object, hello:true, number:3.3, world:undefined
      it "can parse first_", ->
        check_tree "hello ", t3, 2, Object, hello:true, number:undefined, world:undefined
      it "can parse first", ->
        check_tree "hello", t3, 1, Object, hello:true, number:undefined, world:undefined

    it "can fail for invalid", ->
      err = undefined
      try
        result = Types.DoubleBar(Types.Ident((x)->x),
          Types.Number((x)->x))((x,y)->{x:x?.value,y:y?.value})(new Stream(Parser.parse_list_of_component_values("2px")))
      catch e
        err = e
      check err, Types.NoMatch, message:"identifier or number expected but '2px' found"

  describe "Plus", ->
    pl = Types.Plus(Types.Ident(Value))
    it "cannot parse none", ->
      check_error "", pl, 0, "identifier expected but '' found"
    it "cannot parse sth", ->
      check_error "3px", pl, 0, "identifier expected but '3px' found"
    it "can parse one", ->
      check_tree "hello", pl, 1, Array, length:1, 0:"hello"
    it "can parse two", ->
      check_tree "hello world", pl, 3, Array, length:2, 0:"hello", 1:"world"
    it "can parse two sth", ->
      check_tree "hello world 3px", pl, 4, Array, length:2, 0:"hello", 1:"world"
    it "can parse three", ->
      check_tree "hello world/**/haha", pl, 4, Array, length:3, 0:"hello", 1:"world", 2:"haha"
    it "can parse three sth", ->
      check_tree "hello world/**/haha/**/1", pl, 4, Array, length:3, 0:"hello", 1:"world", 2:"haha"

  describe "Star", ->
    st = Types.Star(Types.Ident(Value))
    it "can parse none", ->
      check_tree "", st, 0, Array, length:0
    it "can parse sth", ->
      check_tree "3px", st, 0, Array, length:0
    it "can parse one", ->
      check_tree "hello", st, 1, Array, length:1, 0:"hello"
    it "can parse two", ->
      check_tree "hello world", st, 3, Array, length:2, 0:"hello", 1:"world"
    it "can parse two sth", ->
      check_tree "hello world 3px", st, 4, Array, length:2, 0:"hello", 1:"world"
    it "can parse three", ->
      check_tree "hello world/**/haha", st, 4, Array, length:3, 0:"hello", 1:"world", 2:"haha"
    it "can parse three sth", ->
      check_tree "hello world/**/haha/**/1", st, 4, Array, length:3, 0:"hello", 1:"world", 2:"haha"

  describe "Range", ->
    r00 = Types.Range(0,0)(Types.Ident(Value))
    r01 = Types.Range(0,1)(Types.Ident(Value))
    r02 = Types.Range(0,2)(Types.Ident(Value))
    r11 = Types.Range(1,1)(Types.Ident(Value))
    r12 = Types.Range(1,2)(Types.Ident(Value))
    r13 = Types.Range(1,3)(Types.Ident(Value))
    r22 = Types.Range(2,2)(Types.Ident(Value))
    describe "can parse none", ->
      specify "for 00", -> check_tree "", r00, 0, Array, length:0
      specify "for 01", -> check_tree "", r01, 0, Array, length:0
      specify "for 02", -> check_tree "", r02, 0, Array, length:0
      specify "for 11", -> check_error "", r11, 0, "identifier expected but '' found"
      specify "for 12", -> check_error "", r12, 0, "identifier expected but '' found"
      specify "for 13", -> check_error "", r13, 0, "identifier expected but '' found"
      specify "for 22", -> check_error "", r22, 0, "identifier expected but '' found"
    describe "can parse sth", ->
      specify "for 00", -> check_tree "3px", r00, 0, Array, length:0
      specify "for 01", -> check_tree "3px", r01, 0, Array, length:0
      specify "for 02", -> check_tree "3px", r02, 0, Array, length:0
      specify "for 11", -> check_error "3px", r11, 0, "identifier expected but '3px' found"
      specify "for 12", -> check_error "3px", r12, 0, "identifier expected but '3px' found"
      specify "for 13", -> check_error "3px", r13, 0, "identifier expected but '3px' found"
      specify "for 22", -> check_error "3px", r22, 0, "identifier expected but '3px' found"
    describe "can parse one", ->
      specify "for 00", -> check_tree "hello", r00, 0, Array, length:0
      specify "for 01", -> check_tree "hello", r01, 1, Array, length:1, 0:"hello"
      specify "for 02", -> check_tree "hello", r02, 1, Array, length:1, 0:"hello"
      specify "for 11", -> check_tree "hello", r11, 1, Array, length:1, 0:"hello"
      specify "for 12", -> check_tree "hello", r12, 1, Array, length:1, 0:"hello"
      specify "for 13", -> check_tree "hello", r13, 1, Array, length:1, 0:"hello"
      specify "for 22", -> check_error "hello", r22, 1, "identifier expected but '' found"
    describe "can parse two", ->
      specify "for 00", -> check_tree "hello world", r00, 0, Array, length:0
      specify "for 01", -> check_tree "hello world", r01, 2, Array, length:1, 0:"hello"
      specify "for 02", -> check_tree "hello world", r02, 3, Array, length:2, 0:"hello", 1:"world"
      specify "for 11", -> check_tree "hello world", r11, 2, Array, length:1, 0:"hello"
      specify "for 12", -> check_tree "hello world", r12, 3, Array, length:2, 0:"hello", 1:"world"
      specify "for 13", -> check_tree "hello world", r13, 3, Array, length:2, 0:"hello", 1:"world"
      specify "for 22", -> check_tree "hello world", r22, 3, Array, length:2, 0:"hello", 1:"world"
    describe "can parse two sth", ->
      specify "for 00", -> check_tree "hello world 3px", r00, 0, Array, length:0
      specify "for 01", -> check_tree "hello world 3px", r01, 2, Array, length:1, 0:"hello"
      specify "for 02", -> check_tree "hello world 3px", r02, 4, Array, length:2, 0:"hello", 1:"world"
      specify "for 11", -> check_tree "hello world 3px", r11, 2, Array, length:1, 0:"hello"
      specify "for 12", -> check_tree "hello world 3px", r12, 4, Array, length:2, 0:"hello", 1:"world"
      specify "for 13", -> check_tree "hello world 3px", r13, 4, Array, length:2, 0:"hello", 1:"world"
      specify "for 22", -> check_tree "hello world 3px", r22, 4, Array, length:2, 0:"hello", 1:"world"
    describe "can parse three", ->
      specify "for 00", -> check_tree "hello world/**/haha", r00, 0, Array, length:0
      specify "for 01", -> check_tree "hello world/**/haha", r01, 2, Array, length:1, 0:"hello"
      specify "for 02", -> check_tree "hello world/**/haha", r02, 3, Array, length:2, 0:"hello", 1:"world"
      specify "for 11", -> check_tree "hello world/**/haha", r11, 2, Array, length:1, 0:"hello"
      specify "for 12", -> check_tree "hello world/**/haha", r12, 3, Array, length:2, 0:"hello", 1:"world"
      specify "for 13", -> check_tree "hello world/**/haha", r13, 4, Array, length:3, 0:"hello", 1:"world", 2:"haha"
      specify "for 22", -> check_tree "hello world/**/haha", r22, 3, Array, length:2, 0:"hello", 1:"world"
    describe "can parse three sth", ->
      specify "for 00", -> check_tree "hello world/**/haha/**/1", r00, 0, Array, length:0
      specify "for 01", -> check_tree "hello world/**/haha/**/1", r01, 2, Array, length:1, 0:"hello"
      specify "for 02", -> check_tree "hello world/**/haha/**/1", r02, 3, Array, length:2, 0:"hello", 1:"world"
      specify "for 11", -> check_tree "hello world/**/haha/**/1", r11, 2, Array, length:1, 0:"hello"
      specify "for 12", -> check_tree "hello world/**/haha/**/1", r12, 3, Array, length:2, 0:"hello", 1:"world"
      specify "for 13", -> check_tree "hello world/**/haha/**/1", r13, 4, Array, length:3, 0:"hello", 1:"world", 2:"haha"
      specify "for 22", -> check_tree "hello world/**/haha/**/1", r22, 3, Array, length:2, 0:"hello", 1:"world"


    
