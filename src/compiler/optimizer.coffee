JS = require "./javascript"
walk = require "./walk"

module.exports = Optimizer = (script) ->
  script = remove_empty_stylesheets(script)
  script

remove_empty_stylesheets = walk ->
  if @ instanceof JS.InsertStylesheet
    if ! @value.value.length
      remove: true
    else
      skip: true
    

  

