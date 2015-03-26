# These are the tests for the code generator.
#

SS = require "../../src/compiler/stylesheet"
Parser = require("#{__dirname}/../../src/compiler/parser.coffee")


check_ser = (orig, result=orig) ->
  values = Parser.parse_list_of_component_values(orig)
  (""+values).should.equal(result)

check_st = (orig, result=orig) ->
  value = Parser.parse_stylesheet(orig)
  (""+value).should.equal(result)

describe "Nodes", ->
  describe "Serializer", ->
    describe "list of component values", ->
      it("reserializes '#{str}' correctly", do (str)->-> check_ser(str)) for str in [
        ""
        "^"
        "~"
        "|"
        "-"
        "/"
        "."
        "@"
        "$"
        "*"
        "#"
        "+"
        "3"
        "4"
        "a"
        "e"
        "f"
        "u"
        "U"
        "asdf asdf"
        "asdf/**/asdf"
        "asdf/**/-"
        "asdf/**/4"
        "asdf/**/4%"
        "asdf/**/4px"
        "asdf/**/()"
        "asdf?"
        "@asdf asdf"
        "@asdf/**/asdf"
        "@asdf/**/-"
        "@asdf/**/4"
        "@asdf/**/4%"
        "@asdf/**/4px"
        "@asdf()"
        "@asdf?"
        "#asdf asdf"
        "#asdf/**/asdf"
        "#asdf/**/-"
        "#asdf/**/4"
        "#asdf/**/4%"
        "#asdf/**/4px"
        "#asdf()"
        "#asdf?"
        "3asdf asdf"
        "3asdf/**/asdf"
        "3asdf/**/-"
        "3asdf/**/4"
        "3asdf/**/4%"
        "3asdf/**/4px"
        "3asdf()"
        "3asdf?"
        "# asdf"
        "#/**/asdf"
        "#-"
        "#/**/4"
        "#/**/4%"
        "#/**/4px"
        "#()"
        "#?"
        "- asdf"
        "-/**/asdf"
        "--"
        "-/**/4"
        "-/**/4%"
        "-/**/4px"
        "-()"
        "-?"
        "3 asdf"
        "3/**/asdf"
        "3-"
        "3/**/4"
        "3/**/4%"
        "3/**/4px"
        "3()"
        "3?"
        "@ asdf"
        "@/**/asdf"
        "@/**/-"
        "@4"
        "@4%"
        "@4px"
        "@()"
        "@?"
        ". asdf"
        ".asdf"
        ".-"
        "./**/4"
        "./**/4%"
        "./**/4px"
        ".()"
        ".?"
        "$/**/="
        "$|"
        "$*"
        "*/**/="
        "*|"
        "**"
        "^/**/="
        "^|"
        "^*"
        "~/**/="
        "~|"
        "~*"
        "|/**/="
        "|/**/|"
        "|*"
        "/="
        "/|"
        "//**/*"
        "$="
        "*="
        "^="
        "~="
        "|="
        "||"
        "3px+"
        "+3px"
        "+/**/3px"
        "3cm"
        "3/**/cm"
        "3 cm"
        "3+cm"
        "3e+1"
        "3e-1"
        "3/**/e-1"
        "3e/**/-1"
        "3e-/**/1"
        "f()"
        "f(3px)"
        "f (3px)"
        "f"
        "f/**/(3px)"
        "e/**/f(3px)"
        "4/**/f(3px)"
        "4f(3px)"
        "f(3/**/px)"
        "f10%(3px)"
        "f10(3px)"
        "f/**/10%(3px)"
        "f/**/10(3px)"
      ]
      it("serializes '#{str}' to '#{res}' correctly", do (str,res)->-> check_ser(str,res)) for [str,res] in [
        ["asdf    asdf", "asdf asdf"]
        ["asdf/* hello */asdf", "asdf/**/asdf"]
        ["f10(/**/3px)", "f10(3px)"]
        ["-/**/-", "--"]
        ["/**/", ""]
      ]

    describe "stylesheet", ->
      it "reserializes an empty string", ->
        check_st ""
      it "reserializes whitespace", ->
        check_st "  ", ""
      it "reserializes a single rule", ->
        check_st "a{color:black}", "a { color:black }"
      it "reserializes a single at-rule", ->
        check_st "@asdf ", "@asdf ;"
      it "reserializes a single at-rule", ->
        check_st "@asdf hello", "@asdf hello;"
      it "reserializes a single at-rule", ->
        check_st "@asdf hello{asdf}"