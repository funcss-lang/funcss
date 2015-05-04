TP = require "../../src/compiler/semantics/values/tp_nodes"
DF = require "../../src/compiler/semantics/def/df_nodes"
DefGrammar = require "../../src/compiler/semantics/def/def_grammar"
Stream = require "../../src/compiler/helpers/stream"
Parser = require "../../src/compiler/syntax/parser"
Tokenizer = require "../../src/compiler/syntax/tokenizer"
SS = require "../../src/compiler/syntax/ss_nodes"
check = require "./check"

check_tree = (str, args...) ->
  s = new Stream(Parser.parse_list_of_component_values(str))
  t = DefGrammar.parse(s)
  check t, args...
  t

