module.exports = (tree, clazz, data={}) ->
  unless tree instanceof clazz
    throw new Error(tree + " should be instance of " + clazz.name + " but it is of " + tree.__proto__.constructor.name)
  for k,v of data
    tree[k].should.be.equal(v)
