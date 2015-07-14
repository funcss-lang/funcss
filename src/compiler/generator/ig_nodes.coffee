## Imperative Graph nodes
#
# These nodes represent the imperative constructs of the final generated 
# JavaScript code
#
# *Outputs*
#
# - *`toString()`*: returns the generated JavaScript code
#

assert = require "../helpers/assert"

IG = exports
IG.camel = camel = (s) ->
  return s if s.match(/^--/)
  s.toLowerCase().replace(/-([a-z])/g, (s)->s.charAt(1).toUpperCase())
  

class IG.JSCode
  optimize: -> @

class IG.Statement extends IG.JSCode

class IG.Empty extends IG.Statement
  toString: -> ""

class IG.Require extends IG.Statement
  constructor: (@fileName) ->
  toString: ->
    "require(#{JSON.stringify(@fileName)});"

class IG.BlockStatement extends IG.Statement
  constructor: (@value...) ->
  push: (newStatement) ->
    @value.push newStatement
  optimize: ->
    optimized = super

    v = optimized.value
    i = 0; while i < v.length
      if v[i] instanceof IG.Sequence
        v.splice(i,1,v[i].value...)
      else if i>0 and v[i-1] instanceof IG.DomReady and v[i] instanceof IG.DomReady
        v[i-1].value = v[i-1].value.concat v[i].value
        v.splice(i,1)
      else
        ++i

    optimized

class IG.Sequence extends IG.BlockStatement
  toString: ->
    @value.join('\n')

#
# `JavaScript` is the main script class that outputs the target code.
class IG.FunctionBlock extends IG.BlockStatement
  toString: -> if @value.length then """
    (function(){
    #{@value.join('\n')}
    })();
  """ else ""

# Insert a stylesheet to the `head`, and save it to `var S`
#
class IG.CssStylesheet extends IG.Statement
  constructor: (@value, @name="S") ->
  toString: -> """
    var #{@name} = document.createElement("style");
    document.getElementsByTagName('head')[0].appendChild(#{@name});
    var #{@name}_content = #{JSON.stringify("#{@value}")};
    #{@name}.sheet ?
      #{@name}.innerHTML = #{@name}_content :
      #{@name}.styleSheet.cssText = #{@name}_content;
  """


class IG.Rule extends IG.Statement
  constructor: (@cssStylesheet, @index) ->
  toString: -> """
    var rule#{@index} = #{@cssStylesheet.name}.sheet ? #{@cssStylesheet.name}.sheet.cssRules[#{@index}] : #{@cssStylesheet.name}.styleSheet.rules[#{@index}];
  """
  
class IG.CustomFunction extends IG.BlockStatement
  toString: -> """
    function #{@name}() {
      #{@value.join("\n")}
      return #{@returnValue}
    }
  """

class IG.ListenerManagerDataSource extends IG.Statement
  constructor: (@name, @eventType, @valueOutsideEventHandler, @valueInsideEventHandler) ->
  toString: -> """
    var #{@name} = function() {
        var active = false;
        var rv = new ReactiveVar;
        var activeDependentsById = {};
        var handler = function(event) {
            for (var id in activeDependentsById) {
                rv.set(#{@valueInsideEventHandler});
                return;
            }
            document.removeEventListener("#{@eventType}", handler, false);
            active = false;
        };
        return function(){
            var computation = Tracker.currentComputation;
            if (computation && !(computation._id in activeDependentsById)) {
                activeDependentsById[computation._id] = computation;
                computation.onInvalidate(function() {
                    if (computation.stopped) {
                        delete activeDependentsById[computation._id];
                    }
                })
            }
            if (!active) {
                document.addEventListener("#{@eventType}", handler, false);
                active = true;
                rv.set(#{@valueOutsideEventHandler});
            }
            return rv.get();
        };
    }();
  """

class IG.Expression extends IG.JSCode

class IG.Autorun extends IG.BlockStatement
  toString: -> """
    Tracker.autorun(function() {
      #{@value.join("\n")}
    });
  """

class IG.DomReady extends IG.BlockStatement
  toString: () -> """
    (function() {
      var _funcss_dom_loaded = false;
      function ready() {
        if (_funcss_dom_loaded) return;
        _funcss_dom_loaded = true;
        #{@value.join("\n")}
      }
      (document.addEventListener || document.attachEvent)("DOMContentLoaded", ready);
      (document.addEventListener || document.attachEvent)("readystatechange", ready);
    })();
  """

class IG.SetDeclarationValue extends IG.Statement
  constructor: (@ruleIndex, @name, @value) ->
    assert.present {@value, @name, @ruleIndex}
  toString: () -> """
    rule#{@ruleIndex}.style[#{JSON.stringify camel(@name)}] = #{@value.ssjs()};
  """
  

