Values = require "../../src/compiler/semantics/values"
check = require "./check"
VL = require "../../src/compiler/semantics/values/vl_nodes"

describe "primitive type", ->
  describe "color", ->
    it "parses #fff", ->
      t = check Values.primitiveTypes.color.parse("#fff"), VL.Color
      check t.r, VL.Number, value: 255
      check t.g, VL.Number, value: 255
      check t.b, VL.Number, value: 255
    it "parses #ffffff", ->
      t = check Values.primitiveTypes.color.parse("#ffffff"), VL.Color
      check t.r, VL.Number, value: 255
      check t.g, VL.Number, value: 255
      check t.b, VL.Number, value: 255
    it "parses #ffdd00", ->
      t = check Values.primitiveTypes.color.parse("#ffdd00"), VL.Color
      check t.r, VL.Number, value: 255
      check t.g, VL.Number, value: 221
      check t.b, VL.Number, value: 0
