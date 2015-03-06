module.exports = (tree, clazz, data={}) ->
  if not tree?
    throw new Error("tree is undefined")
  unless tree instanceof clazz
    throw new Error(tree + " should be instance of " + clazz.name + " but it is of " + tree.__proto__.constructor.name)
  for k,v of data
    if v is undefined
      if tree[k]
        throw new Error("#{tree}.#{k} should be undefined")
    else
      if tree[k] is undefined
        throw new Error("#{tree}.#{k} is undefined")
      else
        tree[k].should.be.equal(v)
