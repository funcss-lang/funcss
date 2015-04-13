TP = require "../../src/compiler/semantics/values/tp_nodes"
Stream = require "../../src/compiler/helpers/stream"
Parser = require "../../src/compiler/syntax/parser"
Tokenizer = require "../../src/compiler/syntax/tokenizer"
SS = require "../../src/compiler/syntax/ss_nodes"
check = require "./check"


check_tree = (str, type, next, args...) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  t = type.parse(s)
  check t, args...
  s.position.should.be.equal(next)

check_nomatch = (str, type, pos, message) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  check.error TP.NoMatch, message: message, ->
    t = type.parse(s)
  s.position.should.be.equal(pos)

Value = (x)->x.value
Value100 = (x)->x.value/100
Id = (x)->x

describe 'TP', ->
  describe 'Keyword', ->
    asdf = new TP.Keyword("asdf", Id)

    it "can parse ident", ->
      check_tree "asdf", asdf, 1, SS.IdentToken, value: "asdf"

    it "can parse $x:ident", ->
      result = new TP.Keyword("asdf", (x)->{x:x}).parse(new Stream(Parser.parse_list_of_component_values("asdf")))
      check result, Object
      check result.x, SS.IdentToken, value: "asdf"

  describe 'Number', ->
    number = new TP.Number(Id)
    it "can parse 3", ->
      check_tree "3", number, 1, SS.NumberToken, value: 3, type: "integer"
    it "can parse 3.0", ->
      check_tree "3.0", number, 1, SS.NumberToken, value: 3, type: "number"
    it "cannot parse 'str'", ->
      check_nomatch "'str'", number, 0, "number expected but '\"str\"' found"

  describe 'Integer', ->
    integer = new TP.Integer((x)->x)

    it "can parse 3", ->
      check_tree "3", integer, 1, SS.NumberToken, value: 3, type:"integer"

    it "cannot parse 3.3", ->
      check_nomatch "3.3", integer, 0, "integer expected but '3.3' found"

  describe 'Delimiters', ->
    p = new TP.DelimLike(new SS.DelimToken("+"), (x)->x)

    it "can parse +", ->
      check_tree "+", p, 1, SS.DelimToken, value: "+"

    it "cannot parse 3.3", ->
      check_nomatch "3.3", p, 0, "'+' expected but '3.3' found"

  describe 'Juxtaposition', ->
    jp = new TP.Juxtaposition(new TP.Keyword('black', Value), new TP.Number(Value), (x,y)->{x,y})
    
    it "works", ->
      check_tree "black 3.3", jp, 3, Object, x:"black", y:3.3
    it "fails for first bad type", ->
      check_nomatch "green 3.3", jp, 0, "'black' expected but 'green' found", ->
    it "fails for first EOF", ->
      check_nomatch "", jp, 0, "'black' expected but '' found"
    it "fails for second EOF", ->
      check_nomatch "black", jp, 1, "number expected but '' found"
    it "fails for second _EOF", ->
      check_nomatch "black    ", jp, 2, "number expected but '' found"
    it "fails for second bad type", ->
      check_nomatch "black green", jp, 2, "number expected but 'green' found"

  describe "And", ->
    da = new TP.And(new TP.Ident(Value),new TP.Number(Value), (x,y)->{x,y})
    
    it "can parse first second", ->
      check_tree "black 3.3", da, 3, Object, x:"black", y:3.3
    it "can parse second first", ->
      check_tree "3.3 black", da, 3, Object, x:"black", y:3.3
    
  describe "ExclusiveOr", ->
    bar = new TP.ExclusiveOr(new TP.Ident(Value), new TP.Number(Value), (x)->{value: x})

    it "can parse first", ->
      check_tree "black", bar, 1, Object, value: "black"

    it "can parse second", ->
      check_tree "3.3", bar, 1, Object, value: 3.3

  describe 'InclusiveOr', ->
    it "can parse first branch", ->
      result = new TP.InclusiveOr(new TP.Ident((x)->x),
        new TP.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).parse(new Stream(Parser.parse_list_of_component_values("black")))
      check result, Object, x:"black", y:undefined

    it "can parse the second branch", ->
      result = new TP.InclusiveOr(new TP.Ident((x)->x),
        new TP.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).parse(new Stream(Parser.parse_list_of_component_values("3.3")))
      check result, Object, x:undefined, y:3.3

    it "can parse first second", ->
      result = new TP.InclusiveOr(new TP.Ident((x)->x),
        new TP.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).parse(new Stream(Parser.parse_list_of_component_values("black 3.3")))
      check result, Object, x:"black", y:3.3

    it "can parse second first", ->
      result = new TP.InclusiveOr(new TP.Ident((x)->x),
        new TP.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).parse(new Stream(Parser.parse_list_of_component_values("3.3 black")))
      check result, Object, x:"black", y:3.3

    it "can parse first/**/second", ->
      result = new TP.InclusiveOr(new TP.Ident((x)->x),
        new TP.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).parse(new Stream(Parser.parse_list_of_component_values("black/**/3.3")))
      check result, Object, x:"black", y:3.3

    it "can parse second/**/first", ->
      result = new TP.InclusiveOr(new TP.Ident((x)->x),
        new TP.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).parse(new Stream(Parser.parse_list_of_component_values("3.3/**/black")))
      check result, Object, x:"black", y:3.3

    describe "for three arguments", ->
      t3 = new TP.InclusiveOr(
          new TP.Keyword("hello", ->hello:true),
          new TP.InclusiveOr(
            new TP.Number((x)->number:x.value),
            new TP.Keyword("world", ->world:true),
            (x,y)->number:x?.number,world:y?.world),
          (x,y)->hello:x?.hello,number:y?.number,world:y?.world)

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
        result = new TP.InclusiveOr(new TP.Ident((x)->x),
          new TP.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).parse(new Stream(Parser.parse_list_of_component_values("2px")))
      catch e
        err = e
      check err, TP.NoMatch, message:"identifier or number expected but '2px' found"

  describe "OneOrMore", ->
    pl = new TP.OneOrMore(new TP.Ident(Value))
    it "cannot parse none", ->
      check_nomatch "", pl, 0, "identifier expected but '' found"
    it "cannot parse sth", ->
      check_nomatch "3px", pl, 0, "identifier expected but '3px' found"
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

  describe "ZeroOrMore", ->
    st = new TP.ZeroOrMore(new TP.Ident(Value))
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

  describe "DelimitedByComma", ->
    hs = new TP.DelimitedByComma(new TP.Ident(Value))
    it "cannot parse none", ->
      check_nomatch "", hs, 0, "identifier expected but '' found"
    it "cannot parse sth", ->
      check_nomatch "3px", hs, 0, "identifier expected but '3px' found"
    it "can parse one", ->
      check_tree "hello", hs, 1, Array, length:1, 0:"hello"
    it "can parse one sth", ->
      check_tree "hello world", hs, 2, Array, length:1, 0:"hello"
    it "can parse two", ->
      check_tree "hello,world", hs, 3, Array, length:2, 0:"hello", 1:"world"
    it "can parse _two", ->
      check_tree "hello ,world", hs, 4, Array, length:2, 0:"hello", 1:"world"
    it "can parse two_", ->
      check_tree "hello, world", hs, 4, Array, length:2, 0:"hello", 1:"world"
    it "can parse _two_", ->
      check_tree "hello , world", hs, 5, Array, length:2, 0:"hello", 1:"world"
    it "can parse two sth", ->
      check_tree "hello, world 3px", hs, 5, Array, length:2, 0:"hello", 1:"world"
    it "can parse two, sth", ->
      check_tree "hello, world, 3px", hs, 4, Array, length:2, 0:"hello", 1:"world"
    it "can parse three", ->
      check_tree "hello, world,haha", hs, 6, Array, length:3, 0:"hello", 1:"world", 2:"haha"
    it "can parse three sth", ->
      check_tree "hello, world,haha,1", hs, 6, Array, length:3, 0:"hello", 1:"world", 2:"haha"

  describe "Range", ->
    r00 = new TP.Range(0,0, new TP.Ident(Value))
    r01 = new TP.Range(0,1, new TP.Ident(Value))
    r02 = new TP.Range(0,2, new TP.Ident(Value))
    r11 = new TP.Range(1,1, new TP.Ident(Value))
    r12 = new TP.Range(1,2, new TP.Ident(Value))
    r13 = new TP.Range(1,3, new TP.Ident(Value))
    r22 = new TP.Range(2,2, new TP.Ident(Value))
    describe "can parse none", ->
      specify "for 00", -> check_tree "", r00, 0, Array, length:0
      specify "for 01", -> check_tree "", r01, 0, Array, length:0
      specify "for 02", -> check_tree "", r02, 0, Array, length:0
      specify "for 11", -> check_nomatch "", r11, 0, "identifier expected but '' found"
      specify "for 12", -> check_nomatch "", r12, 0, "identifier expected but '' found"
      specify "for 13", -> check_nomatch "", r13, 0, "identifier expected but '' found"
      specify "for 22", -> check_nomatch "", r22, 0, "identifier expected but '' found"
    describe "can parse sth", ->
      specify "for 00", -> check_tree "3px", r00, 0, Array, length:0
      specify "for 01", -> check_tree "3px", r01, 0, Array, length:0
      specify "for 02", -> check_tree "3px", r02, 0, Array, length:0
      specify "for 11", -> check_nomatch "3px", r11, 0, "identifier expected but '3px' found"
      specify "for 12", -> check_nomatch "3px", r12, 0, "identifier expected but '3px' found"
      specify "for 13", -> check_nomatch "3px", r13, 0, "identifier expected but '3px' found"
      specify "for 22", -> check_nomatch "3px", r22, 0, "identifier expected but '3px' found"
    describe "can parse one", ->
      specify "for 00", -> check_tree "hello", r00, 0, Array, length:0
      specify "for 01", -> check_tree "hello", r01, 1, Array, length:1, 0:"hello"
      specify "for 02", -> check_tree "hello", r02, 1, Array, length:1, 0:"hello"
      specify "for 11", -> check_tree "hello", r11, 1, Array, length:1, 0:"hello"
      specify "for 12", -> check_tree "hello", r12, 1, Array, length:1, 0:"hello"
      specify "for 13", -> check_tree "hello", r13, 1, Array, length:1, 0:"hello"
      specify "for 22", -> check_nomatch "hello", r22, 1, "identifier expected but '' found"
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

    describe "combinations", ->
      describe "of Range", ->
        describe "and Juxtaposition", ->
          c = new TP.Range(0,3, new TP.Juxtaposition(new TP.Ident(Value),new TP.Percentage(Value100), (i,p)->"#{p}=#{i}"))
          it "can parse none", ->
            check_tree "", c, 0, Array, length:0
          it "can parse sth", ->
            check_tree "3px", c, 0, Array, length:0
          it "can parse one", ->
            check_tree "hello 11%", c, 3, Array, length:1, 0:"0.11=hello"
          it "can parse two", ->
            check_tree "hello 5% world 30%", c, 7, Array, length:2, 0:"0.05=hello", 1:"0.3=world"
          it "can parse two sth", ->
            check_tree "hello 5% world 30% 40%", c, 8, Array, length:2, 0:"0.05=hello", 1:"0.3=world"
          it "can parse three", ->
            check_tree "hello 5% world 30%/**/haha 40%", c, 10, Array, length:3, 0:"0.05=hello", 1:"0.3=world", 2:"0.4=haha"
          it "can parse three sth", ->
            check_tree "hello 5% world 30%/**/haha 40%/**/1", c, 10, Array, length:3, 0:"0.05=hello", 1:"0.3=world", 2:"0.4=haha"

  describe "Eof", ->
    eof = new TP.Eof()
    it "can parse empty string", ->
      s = new Stream(Parser.parse_list_of_component_values(""))
      t = eof.parse(s)
      throw "t must be undefined" unless t is undefined
      s.position.should.be.equal(1)
    it "cannot parse anything else", ->
      check_nomatch "3", eof, 0, "EOF expected but '3' found"

  describe "full", ->
    f = new TP.Full(new TP.Keyword("asdf", (x)->{x:x.value}))
    it "can parse asdf", ->
      check_tree "asdf", f, 2, Object, x:"asdf"
    it "cannot parse asdf sth", ->
      check_nomatch "asdf sth", f, 2, "EOF expected but 'sth' found"

  describe "annotation", ->
    a = new TP.AnnotationRoot(new TP.Annotation("hello", new TP.Keyword("world")), (x,m)->m)
    it "works", ->
      check_tree "world", a, 1, Object, hello:"world"

  describe "simple block", ->
    sb = new TP.SimpleBlock(SS.OpeningCurlyToken, new TP.Keyword("hello"), (x)->hello:x)
    it "works", ->
      check_tree "{hello}", sb, 1, Object, hello:"hello"
    it "works", ->
      check_nomatch "{hello world}", sb, 1, "EOF expected but 'world' found"
    it "fails for sth", ->
      check_nomatch "sth", sb, 0, "'{' expected but 'sth' found"
    it "fails for ()", ->
      check_nomatch "(hello world)", sb, 0, "'{' expected but '(hello world)' found"
    
