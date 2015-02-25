Tokenizer = require("#{__dirname}/../../src/tokenizer.coffee")
{
  IdentToken
  FunctionToken
  AtKeywordToken
  HashToken
  StringToken
  BadStringToken
  UrlToken
  BadUrlToken
  DelimToken
  NumberToken
  PercentageToken
  DimensionToken
  UnicodeRangeToken
  IncludeMatchToken
  DashMatchToken
  PrefixMatchToken
  SuffixMatchToken
  SubstringMatchToken
  ColumnToken
  WhitespaceToken
  CDOToken
  CDCToken
  ColonToken
  SemicolonToken
  CommaToken
  OpeningSquareToken
  ClosingSquareToken
  OpeningParenToken
  ClosingParenToken
  OpeningCurlyToken
  ClosingCurlyToken
} = Tokenizer

describe 'Tokenizer', ->
  it "exists", ->
    Tokenizer.should.be.ok
    tokenizer = new Tokenizer
    tokenizer.should.be.instanceOf Tokenizer

  it "has token classes", ->
    Tokenizer.UrlToken.should.be.ok
    urlToken = new Tokenizer.UrlToken("hello")
    urlToken.should.be.instanceOf Tokenizer.UrlToken
    Tokenizer.ColumnToken.should.be.ok
    columnToken = new Tokenizer.ColumnToken()
    columnToken.should.be.instanceOf Tokenizer.ColumnToken

  check = (input, tokens...) ->
    result = new Tokenizer().tokenize(input)
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
    check "/* hello *//* hallo */ ", WhitespaceToken,{}

  it "can tokenize an ident", ->
    check "hello", IdentToken,{value:"hello",}
  it "can tokenize an -ident", ->
    check "-hello", IdentToken,{value:"-hello",}
  it "can tokenize an --ident", ->
    check "--hello", IdentToken,{value:"--hello",}
    
  it "can tokenize a function", ->
    check "f()", FunctionToken,{value:"f",}, ClosingParenToken,{}
    
  it "can tokenize an at-keyword", ->
    check "@asdf", AtKeywordToken,{value:"asdf",}
  it "can tokenize an -at-keyword", ->
    check "@-asdf", AtKeywordToken,{value:"-asdf",}
  it "can tokenize an --at-keyword", ->
    check "@--asdf", AtKeywordToken,{value:"--asdf",}
  it "can tokenize an -9-not-at-keyword", ->
    check "@-9asdf", DelimToken,{value:"@",}, DimensionToken,{value:-9,type:"integer",unit:"asdf",}

  it "can tokenize a hash", ->
    check "#asdf", HashToken,{value:"asdf",type:"id",}
  it "can tokenize a -hash", ->
    check "#-asdf", HashToken,{value:"-asdf",type:"id",}
  it "can tokenize a --hash", ->
    check "#--asdf", HashToken,{value:"--asdf",type:"id",}
  it "can tokenize a non-ident 1hash", ->
    check "#4asd", HashToken,{value:"4asd",type:"unrestricted",}
  it "can tokenize a non-ident -1hash", ->
    check "#-4asd", HashToken,{value:"-4asd",type:"unrestricted",}

  it "can tokenize a string", ->
    check "'hello'", StringToken,{value:"hello",}
  it "can tokenize a bad string", ->
    check "'hello\n", BadStringToken,{}, WhitespaceToken,{}
  it "can tokenize string with escaped linebreak", ->
    check "'hello\\\nasdf'", StringToken,{value:"helloasdf",}

  it "can tokenize a url", ->
    check "url()", UrlToken,{value:"",}
  it "can tokenize a quoted url", ->
    check "url(    'hello ' )", UrlToken,{value:"hello ",}
  it "can tokenize a bad url(\\)", ->
    check "url( hi(\\) )", BadUrlToken,{}
  it "can tokenize an escaped url\\(\\)", ->
    check "url( hi\\(\\) )", UrlToken,{value:"hi()",}
    
  it "can tokenize a #", ->
    check "#", DelimToken,{value:"#",}
  it "can tokenize a *", ->
    check "*", DelimToken,{value:"*",}
  it "can tokenize a -", ->
    check "-", DelimToken,{value:"-",}
  it "can tokenize a .", ->
    check ".", DelimToken,{value:".",}
  it "can tokenize a !", ->
    check "!", DelimToken,{value:"!",}
  it "can tokenize a <", ->
    check "<", DelimToken,{value:"<",}
  it "can tokenize a >", ->
    check ">", DelimToken,{value:">",}
  it "can tokenize a &", ->
    check "&", DelimToken,{value:"&",}
  it "can tokenize a $", ->
    check "$", DelimToken,{value:"$",}
  it "can tokenize a @", ->
    check "@", DelimToken,{value:"@",}
  it "can tokenize a |", ->
    check "|", DelimToken,{value:"|",}
  it "can tokenize a +", ->
    check "+", DelimToken,{value:"+",}
  it "can tokenize a §", ->
    check "§", IdentToken,{value:"§",}
  it "can tokenize a ¬", ->
    check "¬", IdentToken,{value:"¬",}
  it "can tokenize a /", ->
    check "/", DelimToken,{value:"/",}
  it "can tokenize a =", ->
    check "=", DelimToken,{value:"=",}
  it "can tokenize a %", ->
    check "%", DelimToken,{value:"%",}
  it "can tokenize a #delim", ->
    check "#/**/asf", DelimToken,{value:"#",}, IdentToken,{value:"asf",}

  it "can tokenize an integer", ->
    check "3", NumberToken,{value:3,type:"integer",repr:"3"}
  it "can tokenize a number", ->
    check "3.12", NumberToken,{value:3.12,type:"number",repr:"3.12"}
  it "can tokenize a number with a sign", ->
    check "+3.12", NumberToken,{value:3.12,type:"number",repr:"+3.12"}
  it "can tokenize a number in exponential form", ->
    check "3e11", NumberToken,{value:3e11,type:"number",repr:"3e11"}
  it "can tokenize a number with a sign in the exponential form", ->
    check "-3.12e-112", NumberToken,{value:-3.12e-112,type:"number",repr:"-3.12e-112"}

  it "can tokenize an integer percentage", ->
    check "3%", PercentageToken,{value:3,repr:"3",}
  it "can tokenize a percentage", ->
    check "3.12%", PercentageToken,{value:3.12,repr:"3.12"}
  it "can tokenize a percentage with a sign", ->
    check "+3.12%", PercentageToken,{value:3.12,repr:"+3.12"}
  it "can tokenize a percentage in exponential form", ->
    check "3e11%", PercentageToken,{value:3e11,repr:"3e11"}
  it "can tokenize a percentage with a sign in the exponential form", ->
    check "-3.12e-112%", PercentageToken,{value:-3.12e-112,repr:"-3.12e-112"}

  it "can tokenize an integer dimension", ->
    check "3cm", DimensionToken,{value:3,repr:"3",unit:"cm"}
  it "can tokenize a dimension", ->
    check "3.12cm", DimensionToken,{value:3.12,repr:"3.12",unit:"cm"}
  it "can tokenize a dimension with a sign", ->
    check "+3.12cm", DimensionToken,{value:3.12,repr:"+3.12",unit:"cm"}
  it "can tokenize a dimension in exponential form", ->
    check "3e11cm", DimensionToken,{value:3e11,repr:"3e11",unit:"cm"}
  it "can tokenize a dimension with a sign in the exponential form", ->
    check "-3.12e-112cm", DimensionToken,{value:-3.12e-112,repr:"-3.12e-112",unit:"cm"}

  it "can tokenize IncludeMatchToken", ->
    check "~=", IncludeMatchToken,{}
  it "can tokenize DashMatchToken", ->
    check "|=", DashMatchToken,{}
  it "can tokenize PrefixMatchToken", ->
    check "^=", PrefixMatchToken,{}
  it "can tokenize SuffixMatchToken", ->
    check "$=", SuffixMatchToken,{}
  it "can tokenize SubstringMatchToken", ->
    check "*=", SubstringMatchToken,{}
  it "can tokenize ColumnToken", ->
    check "||", ColumnToken,{}

  it "can tokenize whitespace", ->
    check "\n\n    \t\n  \t", WhitespaceToken,{}
  it "can tokenize whitespace", ->
    check "\n\n    /**/\t\n  \t", WhitespaceToken,{}, WhitespaceToken,{}

  it "can tokenize CDOToken", ->
    check "<!--", CDOToken,{}
  it "can tokenize CDCToken", ->
    check "-->", CDCToken,{}

  it "can tokenize a ,", ->
    check ",", CommaToken,{}
  it "can tokenize a :", ->
    check ":", ColonToken,{}
  it "can tokenize a ;", ->
    check ";", SemicolonToken,{}
  it "can tokenize a [", ->
    check "[", OpeningSquareToken,{}
  it "can tokenize a ]", ->
    check "]", ClosingSquareToken,{}
  it "can tokenize a (", ->
    check "(", OpeningParenToken,{}
  it "can tokenize a )", ->
    check ")", ClosingParenToken,{}
  it "can tokenize a {", ->
    check "{", OpeningCurlyToken,{}
  it "can tokenize a }", ->
    check "}", ClosingCurlyToken,{}
