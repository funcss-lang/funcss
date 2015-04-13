IG = require "./ig_nodes"
walk = require "../helpers/walk"


remove_empty_stylesheets = walk ->
  if @ instanceof IG.InsertStylesheet
    if ! @value.value.length
      remove: true
    else
      skip: true
    

  

