Tokenizer = require("#{__dirname}/../../src/compiler/tokenizer.coffee")
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

Parser = require("#{__dirname}/../../src/compiler/parser.coffee")
{
  AtRule
  QualifiedRule
  Declaration
  Function
  SimpleBlock
} = Parser

describe 'Parser', ->
  it "exists", ->
    new Parser().should.be.instanceOf Parser
  it "has tree classes", ->
    new SimpleBlock().should.be.instanceOf SimpleBlock
