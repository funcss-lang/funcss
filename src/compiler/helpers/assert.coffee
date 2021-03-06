exports.present = (values) ->
  for name, value of values
    throw new Error "#{name} must be present" unless value?
  return

exports.hasProp = (values, property) ->
  for name, value of values
    throw new Error "#{name} must be present" unless value?
    throw new Error "#{name} must have property #{property}" unless value[property]?
  return

exports.instanceOf = (values, clazz) ->
  for name, value of values
    throw new Error "#{name} must be present" unless value?
    throw new Error "#{name} must be instance of #{clazz.name}" unless value instanceof clazz
  return

exports.notInstanceOf = (values, clazz) ->
  for name, value of values
    throw new Error "#{name} must be present" unless value?
    throw new Error "#{name} must not be instance of #{clazz.name}" if value instanceof clazz
  return

exports.array = (values, clazz) ->
  for name, value of values
    throw new Error "#{name} must be present" unless value?
    throw new Error "#{name} must be an array" unless value.length?
  return

exports.function = (values, clazz) ->
  for name, value of values
    throw new Error "#{name} must be present" unless value?
    throw new Error "#{name} must be a function" unless value.bind? and value.apply? and value.call?
  return

