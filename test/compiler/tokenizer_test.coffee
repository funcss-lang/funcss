Tokenizer = require "../../src/compiler/tokenizer.coffee"
SS = require "../../src/compiler/stylesheet"

describe 'Tokenizer', ->
  it "has token classes", ->
    SS.UrlToken.should.be.ok
    urlToken = new SS.UrlToken("hello")
    urlToken.should.be.instanceOf SS.UrlToken
    SS.ColumnToken.should.be.ok
    columnToken = new SS.ColumnToken()
    columnToken.should.be.instanceOf SS.ColumnToken

  check = (input, tokens...) ->
    result = Tokenizer.tokenize(input)
    unless tokens.length % 2 is 0
      throw new Error("Please provide a list of pairs of tokens and objects for check()")
    result.should.have.length(tokens.length/2)
    i = 0
    while i < tokens.length
      result[i/2].should.be.instanceOf(tokens[i])
      for k,v of tokens[i+1]
        result[i/2][k].should.be.equal(v)
      i+=2
    



  it "can tokenize an empty string", ->
    check ""

  it "can tokenize a comment", ->
    check "/* hello */"
  it "can tokenize two comments with a whitespace after them", ->
    check "/* hello *//* hallo */ ", SS.WhitespaceToken,{}

  it "can tokenize an ident", ->
    check "hello", SS.IdentToken,{value:"hello",}
  it "can tokenize an -ident", ->
    check "-hello", SS.IdentToken,{value:"-hello",}
  it "can tokenize an --ident", ->
    check "--hello", SS.IdentToken,{value:"--hello",}
    
  it "can tokenize a function", ->
    check "f()", SS.FunctionToken,{value:"f",}, SS.ClosingParenToken,{}
    
  it "can tokenize an at-keyword", ->
    check "@asdf", SS.AtKeywordToken,{value:"asdf",}
  it "can tokenize an -at-keyword", ->
    check "@-asdf", SS.AtKeywordToken,{value:"-asdf",}
  it "can tokenize an --at-keyword", ->
    check "@--asdf", SS.AtKeywordToken,{value:"--asdf",}
  it "can tokenize an -9-not-at-keyword", ->
    check "@-9asdf", SS.DelimToken,{value:"@",}, SS.DimensionToken,{value:-9,type:"integer",unit:"asdf",}

  it "can tokenize a hash", ->
    check "#asdf", SS.HashToken,{value:"asdf",type:"id",}
  it "can tokenize a -hash", ->
    check "#-asdf", SS.HashToken,{value:"-asdf",type:"id",}
  it "can tokenize a --hash", ->
    check "#--asdf", SS.HashToken,{value:"--asdf",type:"id",}
  it "can tokenize a non-ident 1hash", ->
    check "#4asd", SS.HashToken,{value:"4asd",type:"unrestricted",}
  it "can tokenize a non-ident -1hash", ->
    check "#-4asd", SS.HashToken,{value:"-4asd",type:"unrestricted",}

  it "can tokenize a string", ->
    check "'hello'", SS.StringToken,{value:"hello",}
  it "can tokenize a bad string", ->
    check "'hello\n", SS.BadStringToken,{}, SS.WhitespaceToken,{}
  it "can tokenize string with escaped linebreak", ->
    check "'hello\\\nasdf'", SS.StringToken,{value:"helloasdf",}

  it "can tokenize a url", ->
    check "url()", SS.UrlToken,{value:"",}
  it "can tokenize a quoted url", ->
    check "url(    'hello ' )", SS.UrlToken,{value:"hello ",}
  it "can tokenize a bad url(\\)", ->
    check "url( hi(\\) )", SS.BadUrlToken,{}
  it "can tokenize an escaped url\\(\\)", ->
    check "url( hi\\(\\) )", SS.UrlToken,{value:"hi()",}
    
  it "can tokenize a #", ->
    check "#", SS.DelimToken,{value:"#",}
  it "can tokenize a *", ->
    check "*", SS.DelimToken,{value:"*",}
  it "can tokenize a -", ->
    check "-", SS.DelimToken,{value:"-",}
  it "can tokenize a .", ->
    check ".", SS.DelimToken,{value:".",}
  it "can tokenize a !", ->
    check "!", SS.DelimToken,{value:"!",}
  it "can tokenize a <", ->
    check "<", SS.DelimToken,{value:"<",}
  it "can tokenize a >", ->
    check ">", SS.DelimToken,{value:">",}
  it "can tokenize a &", ->
    check "&", SS.DelimToken,{value:"&",}
  it "can tokenize a $", ->
    check "$", SS.DelimToken,{value:"$",}
  it "can tokenize a @", ->
    check "@", SS.DelimToken,{value:"@",}
  it "can tokenize a |", ->
    check "|", SS.DelimToken,{value:"|",}
  it "can tokenize a +", ->
    check "+", SS.DelimToken,{value:"+",}
  it "can tokenize a §", ->
    check "§", SS.IdentToken,{value:"§",}
  it "can tokenize a ¬", ->
    check "¬", SS.IdentToken,{value:"¬",}
  it "can tokenize a /", ->
    check "/", SS.DelimToken,{value:"/",}
  it "can tokenize a =", ->
    check "=", SS.DelimToken,{value:"=",}
  it "can tokenize a %", ->
    check "%", SS.DelimToken,{value:"%",}
  it "can tokenize a #delim", ->
    check "#/**/asf", SS.DelimToken,{value:"#",}, SS.IdentToken,{value:"asf",}

  it "can tokenize an integer", ->
    check "3", SS.NumberToken,{value:3,type:"integer",repr:"3"}
  it "can tokenize a number", ->
    check "3.12", SS.NumberToken,{value:3.12,type:"number",repr:"3.12"}
  it "can tokenize a number with a +sign", ->
    check "+3.12", SS.NumberToken,{value:3.12,type:"number",repr:"+3.12"}
  it "can tokenize a number with a -sign", ->
    check "-3.12", SS.NumberToken,{value:-3.12,type:"number",repr:"-3.12"}
  it "can tokenize a number with a dot", ->
    check ".12", SS.NumberToken,{value:.12,type:"number",repr:".12"}
  it "can tokenize a number with a +sign and a dot", ->
    check "+.12", SS.NumberToken,{value:.12,type:"number",repr:"+.12"}
  it "can tokenize a number with a -sign and a dot", ->
    check "-.12", SS.NumberToken,{value:-.12,type:"number",repr:"-.12"}
  it "can tokenize a number in exponential form", ->
    check "3e11", SS.NumberToken,{value:3e11,type:"number",repr:"3e11"}
  it "can tokenize a number with a sign in the exponential form", ->
    check "-3.12e-112", SS.NumberToken,{value:-3.12e-112,type:"number",repr:"-3.12e-112"}

  it "can tokenize an integer percentage", ->
    check "3%", SS.PercentageToken,{value:3,repr:"3",}
  it "can tokenize a percentage", ->
    check "3.12%", SS.PercentageToken,{value:3.12,repr:"3.12"}
  it "can tokenize a percentage with a sign", ->
    check "+3.12%", SS.PercentageToken,{value:3.12,repr:"+3.12"}
  it "can tokenize a percentage in exponential form", ->
    check "3e11%", SS.PercentageToken,{value:3e11,repr:"3e11"}
  it "can tokenize a percentage with a sign in the exponential form", ->
    check "-3.12e-112%", SS.PercentageToken,{value:-3.12e-112,repr:"-3.12e-112"}

  it "can tokenize an integer dimension", ->
    check "3cm", SS.DimensionToken,{value:3,repr:"3",unit:"cm"}
  it "can tokenize a dimension", ->
    check "3.12cm", SS.DimensionToken,{value:3.12,repr:"3.12",unit:"cm"}
  it "can tokenize a dimension with a sign", ->
    check "+3.12cm", SS.DimensionToken,{value:3.12,repr:"+3.12",unit:"cm"}
  it "can tokenize a dimension in exponential form", ->
    check "3e11cm", SS.DimensionToken,{value:3e11,repr:"3e11",unit:"cm"}
  it "can tokenize a dimension with a sign in the exponential form", ->
    check "-3.12e-112cm", SS.DimensionToken,{value:-3.12e-112,repr:"-3.12e-112",unit:"cm"}

  it "can tokenize SS.IncludeMatchToken", ->
    check "~=", SS.IncludeMatchToken,{}
  it "can tokenize SS.DashMatchToken", ->
    check "|=", SS.DashMatchToken,{}
  it "can tokenize SS.PrefixMatchToken", ->
    check "^=", SS.PrefixMatchToken,{}
  it "can tokenize SS.SuffixMatchToken", ->
    check "$=", SS.SuffixMatchToken,{}
  it "can tokenize SS.SubstringMatchToken", ->
    check "*=", SS.SubstringMatchToken,{}
  it "can tokenize SS.ColumnToken", ->
    check "||", SS.ColumnToken,{}

  it "can tokenize whitespace", ->
    check "\n\n    \t\n  \t", SS.WhitespaceToken,{}
  it "can tokenize whitespace", ->
    check "\n\n    /**/\t\n  \t", SS.WhitespaceToken,{}, SS.WhitespaceToken,{}

  it "can tokenize SS.CDOToken", ->
    check "<!--", SS.CDOToken,{}
  it "can tokenize SS.CDCToken", ->
    check "-->", SS.CDCToken,{}

  it "can tokenize a ,", ->
    check ",", SS.CommaToken,{}
  it "can tokenize a :", ->
    check ":", SS.ColonToken,{}
  it "can tokenize a ;", ->
    check ";", SS.SemicolonToken,{}
  it "can tokenize a [", ->
    check "[", SS.OpeningSquareToken,{}
  it "can tokenize a ]", ->
    check "]", SS.ClosingSquareToken,{}
  it "can tokenize a (", ->
    check "(", SS.OpeningParenToken,{}
  it "can tokenize a )", ->
    check ")", SS.ClosingParenToken,{}
  it "can tokenize a {", ->
    check "{", SS.OpeningCurlyToken,{}
  it "can tokenize a }", ->
    check "}", SS.ClosingCurlyToken,{}
