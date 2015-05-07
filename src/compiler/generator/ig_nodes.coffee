#### JavaScript nodes
#

IG = exports
IG.camel = camel = (s) ->
  return s if s.match(/^--/)
  s.toLowerCase().replace(/-([a-z])/g, (s)->s.charAt(1).toUpperCase())
  

class IG.JSCode
class IG.Statement extends IG.JSCode
class IG.BlockStatement extends IG.Statement
  constructor: (@value...) ->
  push: (newStatement) ->
    @value.push newStatement


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
    #{@name}.innerHTML=#{JSON.stringify("#{@value}")};
    document.head.appendChild(#{@name});
  """


class IG.Rule extends IG.Statement
  constructor: (@cssStylesheet, @index) ->
  toString: -> """
    var rule#{@index} = #{@cssStylesheet.name}.sheet.cssRules[#{@index}];
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
    window.addEventListener("load", function() {
      #{@value.join("\n")}
    });
  """

class IG.SetDeclarationValue extends IG.Statement
  constructor: (@ruleIndex, @name, @value) ->
  toString: () -> debugger; """
    rule#{@ruleIndex}.style[#{JSON.stringify camel(@name)}] = #{@value.ssjs()};
  """
  

