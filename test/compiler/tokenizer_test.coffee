Tokenizer = require "../../src/compiler/tokenizer.coffee"
N = require "../../src/compiler/nodes"

describe 'Tokenizer', ->
  it "has token classes", ->
    N.UrlToken.should.be.ok
    urlToken = new N.UrlToken("hello")
    urlToken.should.be.instanceOf N.UrlToken
    N.ColumnToken.should.be.ok
    columnToken = new N.ColumnToken()
    columnToken.should.be.instanceOf N.ColumnToken

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
    check "/* hello *//* hallo */ ", N.WhitespaceToken,{}

  it "can tokenize an ident", ->
    check "hello", N.IdentToken,{value:"hello",}
  it "can tokenize an -ident", ->
    check "-hello", N.IdentToken,{value:"-hello",}
  it "can tokenize an --ident", ->
    check "--hello", N.IdentToken,{value:"--hello",}
    
  it "can tokenize a function", ->
    check "f()", N.FunctionToken,{value:"f",}, N.ClosingParenToken,{}
    
  it "can tokenize an at-keyword", ->
    check "@asdf", N.AtKeywordToken,{value:"asdf",}
  it "can tokenize an -at-keyword", ->
    check "@-asdf", N.AtKeywordToken,{value:"-asdf",}
  it "can tokenize an --at-keyword", ->
    check "@--asdf", N.AtKeywordToken,{value:"--asdf",}
  it "can tokenize an -9-not-at-keyword", ->
    check "@-9asdf", N.DelimToken,{value:"@",}, N.DimensionToken,{value:-9,type:"integer",unit:"asdf",}

  it "can tokenize a hash", ->
    check "#asdf", N.HashToken,{value:"asdf",type:"id",}
  it "can tokenize a -hash", ->
    check "#-asdf", N.HashToken,{value:"-asdf",type:"id",}
  it "can tokenize a --hash", ->
    check "#--asdf", N.HashToken,{value:"--asdf",type:"id",}
  it "can tokenize a non-ident 1hash", ->
    check "#4asd", N.HashToken,{value:"4asd",type:"unrestricted",}
  it "can tokenize a non-ident -1hash", ->
    check "#-4asd", N.HashToken,{value:"-4asd",type:"unrestricted",}

  it "can tokenize a string", ->
    check "'hello'", N.StringToken,{value:"hello",}
  it "can tokenize a bad string", ->
    check "'hello\n", N.BadStringToken,{}, N.WhitespaceToken,{}
  it "can tokenize string with escaped linebreak", ->
    check "'hello\\\nasdf'", N.StringToken,{value:"helloasdf",}

  it "can tokenize a url", ->
    check "url()", N.UrlToken,{value:"",}
  it "can tokenize a quoted url", ->
    check "url(    'hello ' )", N.UrlToken,{value:"hello ",}
  it "can tokenize a bad url(\\)", ->
    check "url( hi(\\) )", N.BadUrlToken,{}
  it "can tokenize an escaped url\\(\\)", ->
    check "url( hi\\(\\) )", N.UrlToken,{value:"hi()",}
    
  it "can tokenize a #", ->
    check "#", N.DelimToken,{value:"#",}
  it "can tokenize a *", ->
    check "*", N.DelimToken,{value:"*",}
  it "can tokenize a -", ->
    check "-", N.DelimToken,{value:"-",}
  it "can tokenize a .", ->
    check ".", N.DelimToken,{value:".",}
  it "can tokenize a !", ->
    check "!", N.DelimToken,{value:"!",}
  it "can tokenize a <", ->
    check "<", N.DelimToken,{value:"<",}
  it "can tokenize a >", ->
    check ">", N.DelimToken,{value:">",}
  it "can tokenize a &", ->
    check "&", N.DelimToken,{value:"&",}
  it "can tokenize a $", ->
    check "$", N.DelimToken,{value:"$",}
  it "can tokenize a @", ->
    check "@", N.DelimToken,{value:"@",}
  it "can tokenize a |", ->
    check "|", N.DelimToken,{value:"|",}
  it "can tokenize a +", ->
    check "+", N.DelimToken,{value:"+",}
  it "can tokenize a §", ->
    check "§", N.IdentToken,{value:"§",}
  it "can tokenize a ¬", ->
    check "¬", N.IdentToken,{value:"¬",}
  it "can tokenize a /", ->
    check "/", N.DelimToken,{value:"/",}
  it "can tokenize a =", ->
    check "=", N.DelimToken,{value:"=",}
  it "can tokenize a %", ->
    check "%", N.DelimToken,{value:"%",}
  it "can tokenize a #delim", ->
    check "#/**/asf", N.DelimToken,{value:"#",}, N.IdentToken,{value:"asf",}

  it "can tokenize an integer", ->
    check "3", N.NumberToken,{value:3,type:"integer",repr:"3"}
  it "can tokenize a number", ->
    check "3.12", N.NumberToken,{value:3.12,type:"number",repr:"3.12"}
  it "can tokenize a number with a +sign", ->
    check "+3.12", N.NumberToken,{value:3.12,type:"number",repr:"+3.12"}
  it "can tokenize a number with a -sign", ->
    check "-3.12", N.NumberToken,{value:-3.12,type:"number",repr:"-3.12"}
  it "can tokenize a number with a dot", ->
    check ".12", N.NumberToken,{value:.12,type:"number",repr:".12"}
  it "can tokenize a number with a +sign and a dot", ->
    check "+.12", N.NumberToken,{value:.12,type:"number",repr:"+.12"}
  it "can tokenize a number with a -sign and a dot", ->
    check "-.12", N.NumberToken,{value:-.12,type:"number",repr:"-.12"}
  it "can tokenize a number in exponential form", ->
    check "3e11", N.NumberToken,{value:3e11,type:"number",repr:"3e11"}
  it "can tokenize a number with a sign in the exponential form", ->
    check "-3.12e-112", N.NumberToken,{value:-3.12e-112,type:"number",repr:"-3.12e-112"}

  it "can tokenize an integer percentage", ->
    check "3%", N.PercentageToken,{value:3,repr:"3",}
  it "can tokenize a percentage", ->
    check "3.12%", N.PercentageToken,{value:3.12,repr:"3.12"}
  it "can tokenize a percentage with a sign", ->
    check "+3.12%", N.PercentageToken,{value:3.12,repr:"+3.12"}
  it "can tokenize a percentage in exponential form", ->
    check "3e11%", N.PercentageToken,{value:3e11,repr:"3e11"}
  it "can tokenize a percentage with a sign in the exponential form", ->
    check "-3.12e-112%", N.PercentageToken,{value:-3.12e-112,repr:"-3.12e-112"}

  it "can tokenize an integer dimension", ->
    check "3cm", N.DimensionToken,{value:3,repr:"3",unit:"cm"}
  it "can tokenize a dimension", ->
    check "3.12cm", N.DimensionToken,{value:3.12,repr:"3.12",unit:"cm"}
  it "can tokenize a dimension with a sign", ->
    check "+3.12cm", N.DimensionToken,{value:3.12,repr:"+3.12",unit:"cm"}
  it "can tokenize a dimension in exponential form", ->
    check "3e11cm", N.DimensionToken,{value:3e11,repr:"3e11",unit:"cm"}
  it "can tokenize a dimension with a sign in the exponential form", ->
    check "-3.12e-112cm", N.DimensionToken,{value:-3.12e-112,repr:"-3.12e-112",unit:"cm"}

  it "can tokenize N.IncludeMatchToken", ->
    check "~=", N.IncludeMatchToken,{}
  it "can tokenize N.DashMatchToken", ->
    check "|=", N.DashMatchToken,{}
  it "can tokenize N.PrefixMatchToken", ->
    check "^=", N.PrefixMatchToken,{}
  it "can tokenize N.SuffixMatchToken", ->
    check "$=", N.SuffixMatchToken,{}
  it "can tokenize N.SubstringMatchToken", ->
    check "*=", N.SubstringMatchToken,{}
  it "can tokenize N.ColumnToken", ->
    check "||", N.ColumnToken,{}

  it "can tokenize whitespace", ->
    check "\n\n    \t\n  \t", N.WhitespaceToken,{}
  it "can tokenize whitespace", ->
    check "\n\n    /**/\t\n  \t", N.WhitespaceToken,{}, N.WhitespaceToken,{}

  it "can tokenize N.CDOToken", ->
    check "<!--", N.CDOToken,{}
  it "can tokenize N.CDCToken", ->
    check "-->", N.CDCToken,{}

  it "can tokenize a ,", ->
    check ",", N.CommaToken,{}
  it "can tokenize a :", ->
    check ":", N.ColonToken,{}
  it "can tokenize a ;", ->
    check ";", N.SemicolonToken,{}
  it "can tokenize a [", ->
    check "[", N.OpeningSquareToken,{}
  it "can tokenize a ]", ->
    check "]", N.ClosingSquareToken,{}
  it "can tokenize a (", ->
    check "(", N.OpeningParenToken,{}
  it "can tokenize a )", ->
    check ")", N.ClosingParenToken,{}
  it "can tokenize a {", ->
    check "{", N.OpeningCurlyToken,{}
  it "can tokenize a }", ->
    check "}", N.ClosingCurlyToken,{}
