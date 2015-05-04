exports.present = (values) ->
  for name, value of values
    throw new Error "#{name} must be present" unless value?
exports.hasProp = (values, property) ->
  for name, value of values
    throw new Error "#{name} must be present" unless value?
    throw new Error "#{name} must have property #{property}" unless value[property]?
