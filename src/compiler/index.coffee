assert    = require "./helpers/assert"
Syntax    = require "./syntax"
Semantics = require "./semantics"
Generator = require "./generator"

exports.compile = (str, options = {}) ->
  assert.hasProp {options}, "done"
  try
    ss = Syntax(str, options)
    fs = Semantics(ss, options)
    ig = Generator(fs, options)
    js = ig.toString()
  catch e
    options.done(e)
    return
  unless options.browserify is false
    browserify = require "browserify"
    stream     = require "stream"
    path       = require "path"
    s = new stream.Readable()
    s._read = -> # http://stackoverflow.com/a/22085851
    s.push js
    s.push null
    b = browserify s,
      basedir: "."
      paths: [
        path.join(__dirname, "../../rtlib")
      ]
    b.bundle (err,buf) ->
      options.done(err,buf.toString("utf-8"))
  else
    options.done(null, js)
     
    



  
