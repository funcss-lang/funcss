
CS = exports

class CS.SimpleRule
  constructor : (opts) ->
    {@mediaQuery, @selector, @name, @value, @important} = opts
  isConstantMediaQuery: -> false
  isConstantValue: -> false
  isConstantSelector: -> false
  selectorSpecificity: -> [0,0,0]
