Values = require ".."
VL = require "../vl_nodes"
Dimensions = require "../dimensions"

Dimensions.metrics.length.units.vw =
  type: Values.primitiveTypes.length
  jsjs: -> """
    (function(){
      var ws = (window._funcss_windowSize || (window._funcss_windowSize = require("window-size")));
      return ws.windowWidth()/100;
    })()
  """
  ssjs: -> @type.decodejs(@jsjs())

Dimensions.metrics.length.units.vh =
  type: Values.primitiveTypes.length
  jsjs: -> """
    (function(){
      var ws = (window._funcss_windowSize || (window._funcss_windowSize = require("window-size")));
      return ws.windowHeight()/100;
    })()
  """
  ssjs: -> @type.decodejs(@jsjs())
  
Dimensions.metrics.length.units.vmin =
  type: Values.primitiveTypes.length
  jsjs: -> """
    (function(){
      var ws = (window._funcss_windowSize || (window._funcss_windowSize = require("window-size")));
      return Math.min(ws.windowWidth(), ws.windowHeight())/100;
    })()
  """
  ssjs: -> @type.decodejs(@jsjs())

Dimensions.metrics.length.units.vmax =
  type: Values.primitiveTypes.length
  jsjs: -> """
    (function(){
      var ws = (window._funcss_windowSize || (window._funcss_windowSize = require("window-size")));
      return Math.max(ws.windowWidth(), ws.windowHeight())/100;
    })()
  """
  ssjs: -> @type.decodejs(@jsjs())
