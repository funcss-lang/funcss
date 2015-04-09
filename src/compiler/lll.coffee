
#### The Low Level Language nodes
# 
# The nodes defined in this file constitute a tree that represents the most semantical
# representation of the FunCSS stylesheet. It is actually a rule list. 
#
#

exports.RuleList = class RuleList
  constructor : (@value) ->

exports.Rule = class Rule
  constructor : (@mediaQuery, @important, @selectorGroup, @prop, @value) ->


