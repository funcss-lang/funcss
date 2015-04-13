walk = require "../../src/compiler/helpers/walk"
check = require "./check"

describe "walk", ->
  it "visits all children of array", ->
    result = []
    walk(-> result.push(@))([1,2,3])
    check result, Array, 0:1, 1:2, 2:3
