#### JavaScript nodes
#

exports.camel = camel = (s) ->
  return s if s.match(/^--/)
  s.toLowerCase().replace(/-([a-z])/g, (s)->s.charAt(1).toUpperCase())
  

exports.JSCode = class JSCode
exports.Statement = class Statement extends JSCode
exports.BlockStatement = class BlockStatement extends Statement
  constructor: (@value...) ->
  push: (newStatement) ->
    @value.push newStatement


#
# `JavaScript` is the main script class that outputs the target code.
exports.FunctionBlock = class FunctionBlock extends BlockStatement
  toString: -> if @value.length then """
    (function(){
    #{@value.join('\n')}
    })();
  """ else ""

# Insert a stylesheet to the `head`, and save it to `var S`
#
exports.CssStylesheet = class CssStylesheet extends Statement
  constructor: (@value, @name="S") ->
  toString: -> """
    var #{@name} = document.createElement("style");
    #{@name}.innerHTML=#{JSON.stringify("#{@value}")};
    document.head.appendChild(#{@name});
  """


exports.Rule = class Rule extends Statement
  constructor: (@cssStylesheet, @index) ->
  toString: -> """
    var rule#{@index} = #{@cssStylesheet.name}.sheet.cssRules[#{@index}];
  """
  
exports.CustomFunction = class CustomFunction extends BlockStatement
  toString: -> """
    function #{@name}() {
      #{@value.join("\n")}
      return #{@returnValue}
    }
  """

exports.ListenerManagerDataSource = class ListenerManagerDataSource extends Statement
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

exports.Expression = class Expression extends JSCode

exports.Autorun = class Autorun extends BlockStatement
  toString: -> """
    Tracker.autorun(function() {
      #{@value.join("\n")}
    });
  """

exports.DomReady = class DomReady extends BlockStatement
  toString: () -> """
    window.addEventListener("load", function() {
      #{@value.join("\n")}
    });
  """

exports.SetDeclarationValue = class SetDeclarationValue extends Statement
  constructor: (@ruleIndex, @name, @value) ->
  toString: () -> debugger; """
    rule#{@ruleIndex}.style[#{JSON.stringify camel(@name)}] = #{@value.ssjs()};
  """
  

