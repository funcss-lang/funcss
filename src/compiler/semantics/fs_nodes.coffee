## The Functional Stylesheet nodes
#
# These nodes represent the semantic representation of a Functional Stylesheet.
# A Functional Stylesheet contains all interpreted declarations from builtins
# and the lib.
#
# *Outputs*
#
# - `ig(options)` returns the IG graph implementing the behavior of the functional stylesheet.
#    The valid options are:
#
#    * `includeTracker` if false, Tracker will not be included
#    * `includeReactiveVar` if false, ReactiveVar will not be included
#
#

ER         = require "../errors/er_nodes"
assert     = require "../helpers/assert"
Parser     = require "../syntax/parser"
SS         = require "../syntax/ss_nodes"
GR         = require "../syntax/gr_nodes"
VdsGrammar = require "./values/vds_grammar"
Values     = require "./values"
IG         = require "../generator/ig_nodes"
Definitions= require "./definitions"
Imports    = require "./imports"
Cascade    = require "./cascade"
SelGrammar = require "./selectors/sel_grammar"


FS = exports


class FS.FunctionalStylesheet
  constructor: (ss,@options) ->
    @cascade = new Cascade(@)
    @atRuleHandlers = {
      def: @definitions = new Definitions(@)
      import: @imports = new Imports(@)
    }
    vds = (str) =>
      VdsGrammar.parse(str).setFs(@)
    @_propertyTypes = {
      'font-family': vds "[[<family-name> | <generic-family>],]* [<family-name> | <generic-family>]"
      'font-style': vds "normal | italic | oblique"
      'font-variant': vds "normal | small-caps"
      #'font-weight': vds "normal | bold | bolder | lighter | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900"
      'font-weight': vds "normal | bold | bolder | lighter"
      'font-size': vds "<absolute-size> | <relative-size> | <length> | <percentage>"
      'font': vds "[ <'font-style'> || <'font-variant'> || <'font-weight'> ]? <'font-size'> [ / <'line-height'> ]? <'font-family'>"
      'color': vds "<color>"
      'background-image': vds "<url> | none"
      'background-repeat': vds "repeat | repeat-x | repeat-y | no-repeat"
      'background-attachment': vds "scroll | fixed"
      'background-color': vds "<color> | transparent"
      'background-position': vds "[<percentage> | <length>]{1,2} | [top | center | bottom] || [left | center | right]"
      'background': vds "<'background-color'> || <'background-image'> || <'background-repeat'> || <'background-attachment'> || <'background-position'>"
      'word-spacing': vds "normal | <length> "
      'letter-spacing': vds "normal | <length> "
      'text-decoration': vds "none | [ underline || overline || line-through || blink ]"
      'vertical-align': vds "baseline | sub | super | top | text-top | middle | bottom | text-bottom | <percentage> "
      'text-transform': vds "capitalize | uppercase | lowercase | none"
      'text-align': vds "left | right | center | justify"
      'text-indent': vds "<length> | <percentage>"
      'line-height': vds "normal | <number> | <length> | <percentage>"
      'margin-top': vds "<length> | <percentage> | auto"
      'margin-right': vds "<length> | <percentage> | auto"
      'margin-bottom': vds "<length> | <percentage> | auto"
      'margin-left': vds "<length> | <percentage> | auto"
      'margin': vds "[ <length> | <percentage> | auto ]{1,4} "
      'padding-top': vds "<length> | <percentage>"
      'padding-right': vds "<length> | <percentage>"
      'padding-bottom': vds "<length> | <percentage>"
      'padding-left': vds "<length> | <percentage>"
      'padding': vds "[ <length> | <percentage> ]{1,4}"
      'border-top-width': vds "thin | medium | thick | <length>"
      'border-right-width': vds "thin | medium | thick | <length>"
      'border-bottom-width': vds "thin | medium | thick | <length>"
      'border-left-width': vds "thin | medium | thick | <length>"
      'border-width': vds "[thin | medium | thick | <length>]{1,4}"
      'border-color': vds "<color>{1,4}"
      'border-style': vds "none | dotted | dashed | solid | double | groove | ridge | inset | outset"
      'border-top': vds "<'border-top-width'> || <'border-style'> || <color>"
      'border-right': vds "<'border-right-width'> || <'border-style'> || <color>"
      'border-bottom': vds "<'border-bottom-width'> || <'border-style'> || <color>"
      'border-left': vds "<'border-left-width'> || <'border-style'> || <color>"
      'border': vds "<'border-width'> || <'border-style'> || <color>"
      'width': vds "<length> | <percentage> | auto"
      'height': vds "<length> | auto | <percentage>" # TODO Mockup
      'float': vds "left | right | none"
      'clear': vds "none | left | right | both"
      'display': vds "block | inline | list-item | none"
      'white-space': vds "normal | pre | nowrap"
      'list-style-type': vds "disc | circle | square | decimal | lower-roman | upper-roman | lower-alpha | upper-alpha | none"
      'list-style-image': vds "<url> | none"
      'list-style-position': vds "inside | outside"
      'list-style': vds "[disc | circle | square | decimal | lower-roman | upper-roman | lower-alpha | upper-alpha | none] || [inside | outside] || [<url> | none]"
      'opacity': vds "<number>"
      'content': vds "none | [<string>]+" # TODO mockup
      'transform': vds "none | rotate(<angle>) | scale(<number>) | translate(<length>, <length>)" # TODO mockup
      'top': vds "<length>"  #TODO mockup
      'left': vds "<length>"  #TODO mockup
      'position': vds "absolute | relative | static | fixed"  #TODO mockup
      'overflow': vds "visible | hidden | auto"  #TODO mockup
    }
    @_typeStack = [
      Values.primitiveTypes,
      {
        'family-name': vds "<string>"
        'generic-family': vds "serif|sans-serif|cursive|fantasy|monospace"
        'absolute-size': vds "[ xx-small | x-small | small | medium | large | x-large | xx-large ]"
        'relative-size': vds "[ larger | smaller ]"
      },
      {}
    ]
    

    @consume_stylesheet(ss) if ss?

  getPropertyType: (name, require=true) ->
    if (type = @_propertyTypes[name])?
      return type
    throw new ER.UnknownProperty(name) if require

  setPropertyType: (name, newType) ->
    oldType = @getPropertyType(name, false)
    @_propertyTypes[name] =
      if oldType?
        new GR.ExclusiveOr(oldType, newType)
      else
        newType

  getType: (name, require=true) ->
    for i in [@_typeStack.length-1..0]
      if (type = @_typeStack[i][name])?
        console.debug "read type <#{name}> = #{type}" if console.debug
        return type
    throw new ER.UnknownType(name) if require

  setType: (name, newType) ->
    console.debug "saved type <#{name}> = #{newType}" if console.debug
    assert.present {name}
    oldType = @getType(name, false)
    @_typeStack[@_typeStack.length-1][name] =
      if oldType?
        type = new GR.ExclusiveOr(newType, oldType).setFs(@)
        type.decodejs = oldType.decodejs
        type
      else
        newType
    return oldType

    

  pushScope: () ->
    console.debug? "pushed stack"
    @_typeStack.push {}
    return

  popScope: () ->
    console.debug? "popped stack"
    @_typeStack.pop {}
    return

  consume_stylesheet: (ss) ->
    for rule in ss.value
      if rule instanceof SS.QualifiedRule
        @consume_qualified_rule(rule)
      else if rule instanceof SS.AtRule
        @consume_at_rule(rule)
      else
        throw new Error "Internal error in FunCSS: Unknown rule type in SS.Stylesheet"
    return

  consume_at_rule: (rule) ->
    handler = @atRuleHandlers[rule.name]
    throw new ER.UnknownAtRule(rule.name) unless handler?
    handler.consume_at_rule(rule)
    return

    
  consume_qualified_rule: (qrule) ->
    sel = SelGrammar.parse(qrule.prelude)
    for decl in Parser.parse_list_of_declarations qrule.value.value
      @cascade.consume_declaration(sel, decl)
    return

  ig: (options) ->
    ig = new IG.FunctionBlock
    unless options.includeTracker is false
      ig.push new IG.Require "tracker"
    unless options.includeReactiveVar is false
      ig.push new IG.Require "reactive-var"
    ig.push @definitions.ig()
    ig.push @cascade.ig()
    ig




    
class FS.SimpleRule
  constructor: (opts) ->
    {@mediaQuery, @selector, @name, @value, @important} = opts
    assert.present {@selector, @name, @value, @important}
  isConstantMediaQuery: -> false
  isConstantValue: -> false
  isConstantSelector: -> false
  selectorSpecificity: -> [0,0,0]




