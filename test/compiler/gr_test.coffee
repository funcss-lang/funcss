GR = require "../../src/compiler/semantics/../syntax/gr_nodes"
Parser = require "../../src/compiler/syntax/parser"
Tokenizer = require "../../src/compiler/syntax/tokenizer"
SS = require "../../src/compiler/syntax/ss_nodes"
check = require "./check"


check_tree = (str, type, next, args...) ->
  s = new GR.Stream(Parser.parse_list_of_component_values(str))
  t = type.consume(s)
  check t, args...
  s.position.should.be.equal(next)
  t

check_nomatch = (str, type, pos, message) ->
  s = new GR.Stream(Parser.parse_list_of_component_values(str))
  check.error GR.NoMatch, message: message, ->
    t = type.consume(s)
  s.position.should.be.equal(pos)

Value = (x)->x.value
Value100 = (x)->x.value/100
Id = (x)->x

describe 'GR', ->
  describe 'Keyword', ->
    asdf = new GR.Keyword("asdf", Id)

    it "can parse ident", ->
      check_tree "asdf", asdf, 1, SS.IdentToken, value: "asdf"

    it "can parse $x:ident", ->
      result = new GR.Keyword("asdf", (x)->{x:x}).consume(new GR.Stream(Parser.parse_list_of_component_values("asdf")))
      check result, Object
      check result.x, SS.IdentToken, value: "asdf"

  describe 'Number', ->
    number = new GR.Number(Id)
    it "can parse 3", ->
      check_tree "3", number, 1, SS.NumberToken, value: 3, type: "integer"
    it "can parse 3.0", ->
      check_tree "3.0", number, 1, SS.NumberToken, value: 3, type: "number"
    it "cannot parse 'str'", ->
      check_nomatch "'str'", number, 0, "number expected but '\"str\"' found"

  describe 'Integer', ->
    integer = new GR.Integer((x)->x)

    it "can parse 3", ->
      check_tree "3", integer, 1, SS.NumberToken, value: 3, type:"integer"

    it "cannot parse 3.3", ->
      check_nomatch "3.3", integer, 0, "integer expected but '3.3' found"

  describe 'Delimiters', ->
    p = new GR.DelimLike(new SS.DelimToken("+"), (x)->x)

    it "can parse +", ->
      check_tree "+", p, 1, SS.DelimToken, value: "+"

    it "cannot parse 3.3", ->
      check_nomatch "3.3", p, 0, "'+' expected but '3.3' found"

  describe 'Juxtaposition', ->
    jp = new GR.Juxtaposition(new GR.Keyword('black', Value), new GR.Number(Value), (x,y)->{x,y})
    
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
    da = new GR.And(new GR.Ident(Value),new GR.Number(Value), (x,y)->{x,y})
    
    it "can parse first second", ->
      check_tree "black 3.3", da, 3, Object, x:"black", y:3.3
    it "can parse second first", ->
      check_tree "3.3 black", da, 3, Object, x:"black", y:3.3
    
  describe "ExclusiveOr", ->
    bar = new GR.ExclusiveOr(new GR.Ident(Value), new GR.Number(Value), (x)->{value: x})

    it "can parse first", ->
      check_tree "black", bar, 1, Object, value: "black"

    it "can parse second", ->
      check_tree "3.3", bar, 1, Object, value: 3.3

  describe 'InclusiveOr', ->
    it "can parse first branch", ->
      result = new GR.InclusiveOr(new GR.Ident((x)->x),
        new GR.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).consume(new GR.Stream(Parser.parse_list_of_component_values("black")))
      check result, Object, x:"black", y:undefined

    it "can parse the second branch", ->
      result = new GR.InclusiveOr(new GR.Ident((x)->x),
        new GR.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).consume(new GR.Stream(Parser.parse_list_of_component_values("3.3")))
      check result, Object, x:undefined, y:3.3

    it "can parse first second", ->
      result = new GR.InclusiveOr(new GR.Ident((x)->x),
        new GR.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).consume(new GR.Stream(Parser.parse_list_of_component_values("black 3.3")))
      check result, Object, x:"black", y:3.3

    it "can parse second first", ->
      result = new GR.InclusiveOr(new GR.Ident((x)->x),
        new GR.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).consume(new GR.Stream(Parser.parse_list_of_component_values("3.3 black")))
      check result, Object, x:"black", y:3.3

    it "can parse first/**/second", ->
      result = new GR.InclusiveOr(new GR.Ident((x)->x),
        new GR.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).consume(new GR.Stream(Parser.parse_list_of_component_values("black/**/3.3")))
      check result, Object, x:"black", y:3.3

    it "can parse second/**/first", ->
      result = new GR.InclusiveOr(new GR.Ident((x)->x),
        new GR.Number((x)->x), (x,y)->{x:x?.value,y:y?.value}).consume(new GR.Stream(Parser.parse_list_of_component_values("3.3/**/black")))
      check result, Object, x:"black", y:3.3

    describe "for three arguments", ->
      t3 = new GR.InclusiveOr(
          new GR.Keyword("hello", ->hello:true),
          new GR.InclusiveOr(
            new GR.Number((x)->number:x.value),
            new GR.Keyword("world", ->world:true),
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
      check.error GR.NoMatch, message:"identifier or number expected but '2px' found", ->
        new GR.InclusiveOr(
          new GR.Ident((x)->x),
          new GR.Number((x)->x),
          (x,y)->{x:x?.value,y:y?.value}
        ).consume(new GR.Stream(Parser.parse_list_of_component_values("2px")))

  describe "OneOrMore", ->
    pl = new GR.OneOrMore(new GR.Ident(Value))
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
    st = new GR.ZeroOrMore(new GR.Ident(Value))
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
    hs = new GR.DelimitedByComma(new GR.Ident(Value))
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
    r00 = new GR.Range(0,0, new GR.Ident(Value))
    r01 = new GR.Range(0,1, new GR.Ident(Value))
    r02 = new GR.Range(0,2, new GR.Ident(Value))
    r11 = new GR.Range(1,1, new GR.Ident(Value))
    r12 = new GR.Range(1,2, new GR.Ident(Value))
    r13 = new GR.Range(1,3, new GR.Ident(Value))
    r22 = new GR.Range(2,2, new GR.Ident(Value))
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
          c = new GR.Range(0,3, new GR.Juxtaposition(new GR.Ident(Value),new GR.Percentage(Value100), (i,p)->"#{p}=#{i}"))
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

  describe "empty", ->
    e = new GR.Empty(()->{x:"hello"})
    it "can parse ''", ->
      check_tree "", e, 0, Object, x:"hello"
    it "does not mind ' '", ->
      check_tree " ", e, 0, Object, x:"hello"

  describe "annotation", ->
    a = new GR.AnnotationRoot(new GR.Annotation("hello", new GR.ExclusiveOr(
      new GR.Keyword("world"),
      new GR.Keyword("john"))), (x,m)->m)
    it "works", ->
      check_tree "world", a, 1, Object, hello:"world"
      check_tree "john", a, 1, Object, hello:"john"

  describe "simple block", ->
    sb = new GR.SimpleBlock(SS.OpeningCurlyToken, new GR.Keyword("hello"), (x)->hello:x)
    it "works", ->
      check_tree "{hello}", sb, 1, Object, hello:"hello"
    it "fails for late closing", ->
      check_nomatch "{hello world}", sb, 1, "'}' expected but 'world' found"
    it "fails for early closing", ->
      check_nomatch "{ }", sb, 1, "'hello' expected but '}' found"
    it "fails for sth", ->
      check_nomatch "sth", sb, 0, "'{' expected but 'sth' found"
    it "fails for ()", ->
      check_nomatch "(hello world)", sb, 0, "'{' expected but '(' found"
    
  describe "functional notation", ->
    fn = new GR.FunctionalNotation("tan", new GR.Keyword("hello"), (x)->hello:x)
    it "works", ->
      check_tree "tan(hello)", fn, 1, Object, hello:"hello"
    it "works with whitespace", ->
      check_tree "tan(  hello  )", fn, 1, Object, hello:"hello"
    it "fails for late closing", ->
      check_nomatch "tan(hello world)", fn, 1, "')' expected but 'world' found"
    it "fails for early closing", ->
      check_nomatch "tan()", fn, 1, "'hello' expected but ')' found"
    it "fails for sth", ->
      check_nomatch "sth", fn, 0, "'tan(' expected but 'sth' found"

  describe "CustomFunction", ->
    fn = new GR.AnyFunctionalNotation(new GR.Keyword("hello"), (name, hello)->{name,hello})
    it "works", ->
      check_tree "f(hello)", fn, 1, Object, name:"f", hello:"hello"
    it "works with whitespace", ->
      check_tree "f(  hello  )", fn, 1, Object, name:"f", hello:"hello"
    it "fails for late closing", ->
      check_nomatch "f(hello world)", fn, 1, "')' expected but 'world' found"
    it "fails for early closing", ->
      check_nomatch "f()", fn, 1, "'hello' expected but ')' found"
    it "fails for sth", ->
      check_nomatch "sth", fn, 0, "function expected but 'sth' found"

  describe "RawTokens", ->
    rt = new GR.RawTokens()
    it "works", ->
      t = check_tree "hello 3 f(x)", rt, 5, SS.ComponentValueList, length: 5
      check t[0], SS.IdentToken, value: "hello"
      check t[1], SS.WhitespaceToken
      check t[2], SS.NumberToken, value: 3
      check t[3], SS.WhitespaceToken
      check t[4], SS.Function, name: "f"
      check t[4].value, SS.ComponentValueList, length:1
      check t[4].value[0], SS.IdentToken, value:"x"
