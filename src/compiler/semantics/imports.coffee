
ER         = require "../errors/er_nodes"
GR         = require "../syntax/gr_nodes"
path       = require "path"
fs         = require "fs"
Syntax     = require "../syntax"


module.exports = class Imports
  constructor: (@fs) ->
  consume_at_rule: (atrule) ->
    throw new ER.BlockNotAllowed("@import") if atrule.value?
    fileName = new GR.String().parse(atrule.prelude, ';')
    if /^\./.exec fileName
      # Relative paths are loaded
    else
      if fs.existsSync (f = path.join("#{__dirname}/../../../stdlib", fileName))
        fileName = f
      else if fs.existsSync (f = path.join("#{__dirname}/../../../stdlib", fileName+".fcss"))
        fileName = f
      else
        throw new ER.IncludeFileNotFound fileName
    str = fs.readFileSync(fileName).toString("utf-8")
    ss = Syntax(str, @fs.options)
    console.debug? "read file #{fileName}"
    console.debug? "contents:\n#{ss.value.length}"
    @fs.consume_stylesheet(ss)


      



