# This file is responsible for the simple BDD framework of the project.
#
# Files in the 

fs = require "fs"
path = require "path"
FunCSS = require "../src/compiler"

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
    it "compiles #{basename}", do (basename) -> (done) ->
      if fs.existsSync("#{basename}.fail")
        message = fs.readFileSync("#{basename}.fail", encoding: 'utf-8')
        throw new Error "`#{basename}` failed manual verification: #{message}"
      fcss = fs.readFileSync("#{basename}.fcss", encoding: 'utf-8')
      if fs.existsSync("#{basename}.js")
        js =  fs.readFileSync("#{basename}.js", encoding: 'utf-8')
      else if fs.existsSync("#{basename}.err")
        err =  fs.readFileSync("#{basename}.err", encoding: 'utf-8')
      else
        throw new Error "#{basename} does not have a result. Use `./script/bdd #{path.basename basename} try` to generate one, then verify it manually."
      result = FunCSS.compile fcss,
        includeReactiveVar: false
        includeTracker: false
        browserify: false
        done: (e, result) ->
          if js?
            if e?
              throw e
            result = result.trim().replace(/\s+/g, " ")
            expected = js.trim().replace(/\s+/g, " ")
            result.should.equal(expected)
          else if err?
            if e?
              e.createStack()
              e.stack.should.equal(err)
            else
              throw new Error "#{basename} should have failed with an error, but it succeeded."
          if fs.existsSync("#{basename}.verify")
            throw new Error "`#{basename}` needs manual verification. Use `./script/bdd #{path.basename basename} ok` to confirm it."
          done()




