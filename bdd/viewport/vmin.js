!function e(t, n, r) {
  function s(o, u) {
    if (!n[o]) {
      if (!t[o]) {
        var a = "function" == typeof require && require;
        if (!u && a) {
          return a(o, !0);
        }
        if (i) {
          return i(o, !0);
        }
        var f = new Error("Cannot find module '" + o + "'");
        throw f.code = "MODULE_NOT_FOUND", f;
      }
      var l = n[o] = {
        exports: {}
      };
      t[o][0].call(l.exports, function(e) {
        var n = t[o][1][e];
        return s(n ? n : e);
      }, l, l.exports, e, t, n, r);
    }
    return n[o].exports;
  }
  for (var i = "function" == typeof require && require, o = 0; o < r.length; o++) {
    s(r[o]);
  }
  return s;
}({
  1: [ function(require, module, exports) {
    !function() {
      var pageRect = function() {
        var active = !1, rv = new ReactiveVar(), activeDependentsById = {}, handler = function(event) {
          for (var id in activeDependentsById) {
            rv.set(document.documentElement.getBoundingClientRect());
            return;
          }
          window.removeEventListener("resize", handler, !1);
          active = !1;
        };
        return function() {
          var computation = Tracker.currentComputation;
          if (computation && !(computation._id in activeDependentsById)) {
            activeDependentsById[computation._id] = computation;
            computation.onInvalidate(function() {
              computation.stopped && delete activeDependentsById[computation._id];
            });
          }
          if (!active) {
            window.addEventListener("resize", handler, !1);
            active = !0;
            rv.set(document.documentElement.getBoundingClientRect());
          }
          return rv.get();
        };
      }();
      window.setTimeout(pageRect(), 100);
      module.exports = {
        pageWidth: function() {
          return pageRect().width;
        },
        pageHeight: function() {
          return pageRect().height;
        },
        windowWidth: function() {
          pageRect();
          return window.innerWidth;
        },
        windowHeight: function() {
          pageRect();
          return window.innerHeight;
        }
      };
    }();
  }, {} ],
  2: [ function(require, module, exports) {
    !function() {
      var S = document.createElement("style");
      document.getElementsByTagName("head")[0].appendChild(S);
      var S_content = "div {  }\ndiv {  }\ndiv {  }";
      S.sheet ? S.innerHTML = S_content : S.styleSheet.cssText = S_content;
      var rule0 = S.sheet ? S.sheet.cssRules[0] : S.styleSheet.rules[0], rule1 = S.sheet ? S.sheet.cssRules[1] : S.styleSheet.rules[1], rule2 = S.sheet ? S.sheet.cssRules[2] : S.styleSheet.rules[2];
      !function() {
        function ready() {
          if (!_funcss_dom_loaded) {
            _funcss_dom_loaded = !0;
            Tracker.autorun(function() {
              rule0.style.width = "" + 95 * function() {
                var ws = window._funcss_windowSize || (window._funcss_windowSize = require("window-size"));
                return Math.min(ws.windowWidth(), ws.windowHeight()) / 100;
              }() + "px";
            });
            Tracker.autorun(function() {
              rule1.style.height = "" + 95 * function() {
                var ws = window._funcss_windowSize || (window._funcss_windowSize = require("window-size"));
                return Math.min(ws.windowWidth(), ws.windowHeight()) / 100;
              }() + "px";
            });
            Tracker.autorun(function() {
              rule2.style.backgroundColor = "rgb(" + Math.round("255") + "," + Math.round("0") + "," + Math.round("0") + ")";
            });
          }
        }
        var _funcss_dom_loaded = !1;
        (document.addEventListener || document.attachEvent)("DOMContentLoaded", ready);
        (document.addEventListener || document.attachEvent)("readystatechange", ready);
      }();
    }();
  }, {
    "window-size": 1
  } ]
}, {}, [ 2 ]);