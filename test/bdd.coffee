# This file is responsible for the simple BDD framework of the project.
#
# Files in the 

fs = require "fs"
path = require "path"
FunCSS = require "../src/compiler/funcss"

exports.search = search = (dir) ->
  result = []
  for filename in fs.readdirSync(dir)
    file = path.resolve(dir, filename)
    if fs.statSync(file).isDirectory()
      result = result.concat search(file)
    else
      if filename.match /\.fcss$/
        result.push file
  result

exports.find = find = (testName) ->
  [file] = (f for f in search("bdd") when f.match(new RegExp "#{testName}\.fcss$"))
  throw new Error("Test #{testName} not found.") unless file?
  file

return unless describe?

describe "FunCSS compiler", ->
  for filename in search("bdd")
    basename = filename.replace(/\.fcss$/, "")
    it "compiles #{basename}", do (basename) -> ->
      fcss = fs.readFileSync("#{basename}.fcss", encoding: 'utf-8')
      js =  fs.readFileSync("#{basename}.js", encoding: 'utf-8')
      result = FunCSS.compile(fcss)
      result = result.trim().replace(/\s+/g, " ")
      expected = js.trim().replace(/\s+/g, " ")
      result.should.equal(expected)
      if fs.existsSync("#{basename}.verify")
        throw new Error "#{basename} needs manual verification"
      if fs.existsSync("#{basename}.fail")
        message = fs.readFileSync("#{basename}.fail", encoding: 'utf-8')
        throw new Error "#{basename} failed manual verification: #{message}"




