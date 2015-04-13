module.exports = (fn) -> walkChild = (node) ->
  if node instanceof Array
    i = 0
    while i < node.length
      action = fn.apply(node[i]) ? {}
      if action.remove
        node.splice(i,1)
      else if !action.skip
        walkChild(node[i])
        ++i
      else
        ++i
  else if node.value?
    walkChild(node.value)
  return node

