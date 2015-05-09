GR = require "../../src/compiler/semantics/../syntax/gr_nodes"
DF = require "../../src/compiler/semantics/definitions/df_nodes"
DefGrammar = require "../../src/compiler/semantics/definitions/def_grammar"
Stream = require "../../src/compiler/helpers/stream"
Parser = require "../../src/compiler/syntax/parser"
Tokenizer = require "../../src/compiler/syntax/tokenizer"
SS = require "../../src/compiler/syntax/ss_nodes"
check = require "./check"

check_type = (str, args...) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  df = DefGrammar.parse(s)
  t = df.grammar()
  check t, args...
  t

describe "@def", ->
  it "can make a type", ->
    t = check_type "x() : number = 4", GR.Type


