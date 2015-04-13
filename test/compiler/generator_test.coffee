IG = require "../../src/compiler/generator/ig_nodes"

describe "camel", ->
  it "works for ''", ->
    IG.camel("").should.equal("")
  it "works for '-'", ->
    IG.camel("-").should.equal("-")
  # camelization should skip custom variable names
  it "works for '--asdf'", ->
    IG.camel("--asdf").should.equal("--asdf")
  it "works for '--asdf-gh'", ->
    IG.camel("--asdf-gh").should.equal("--asdf-gh")
  it "works for a", ->
    IG.camel("a").should.equal("a")
  it "works for A", ->
    IG.camel("A").should.equal("a")
  it "works for a-z", ->
    IG.camel("a-z").should.equal("aZ")
  it "works for hello-world", ->
    IG.camel("hello-world").should.equal("helloWorld")
