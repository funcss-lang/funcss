GR = require "../../src/compiler/semantics/../syntax/gr_nodes"
DF = require "../../src/compiler/semantics/definitions/df_nodes"
DefGrammar = require "../../src/compiler/semantics/definitions/def_grammar"
Parser = require "../../src/compiler/syntax/parser"
Tokenizer = require "../../src/compiler/syntax/tokenizer"
SS = require "../../src/compiler/syntax/ss_nodes"
FS = require "../../src/compiler/semantics/fs_nodes"
check = require "./check"

check_type = (str, args...) ->
  df = DefGrammar.parse(str)
  fs = new FS.FunctionalStylesheet
  t = df.grammar(fs)
  t.fs.should.equal(fs)
  check t, args...
  t

describe "@def", ->
  it "can make a type", ->
    t = check_type "x() : number = 4", GR.Type


