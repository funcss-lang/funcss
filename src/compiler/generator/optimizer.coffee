walk = require "../helpers/walk"
IG   = require "./ig_nodes"


remove_empty_stylesheets = walk ->
  if @ instanceof IG.InsertStylesheet
    if ! @value.value.length
      remove: true
    else
      skip: true
    

  

