
FunCSS = require "../compiler"
fs = require "fs"

module.exports =
  run: ->
    content = fs.readFileSync(process.argv[2]).toString("utf-8")
    result = FunCSS.compile(content)
    console.log(result)

