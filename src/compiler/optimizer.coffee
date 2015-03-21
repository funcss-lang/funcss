SS = require "./stylesheet"
walk = require "./walk"

module.exports = Optimizer = (script) ->
  script = remove_empty_stylesheets(script)
  script

remove_empty_stylesheets = walk ->
  if @ instanceof SS.InsertStylesheet
    if ! @value.value.length
      remove: true
    else
      skip: true
    

  

