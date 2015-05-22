
FunCSS = require "../compiler"
fs = require "fs"

exports.run = ->
  content = fs.readFileSync(process.argv[2]).toString("utf-8")
  FunCSS.compile content,
    done: (err, result) ->
      if err
        console.error(err.stack)
      else
        console.log(result)

