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
      var pageMouseXY = function() {
        var active = !1, rv = new ReactiveVar(), activeDependentsById = {}, handler = function(event) {
          for (var id in activeDependentsById) {
            rv.set({
              x: event.pageX,
              y: event.pageY
            });
            return;
          }
          document.removeEventListener("mousemove", handler, !1);
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
            document.addEventListener("mousemove", handler, !1);
            active = !0;
            rv.set({
              x: 0,
              y: 0
            });
          }
          return rv.get();
        };
      }();
      module.exports = {
        pageMouseX: function() {
          return pageMouseXY().x;
        },
        pageMouseY: function() {
          return pageMouseXY().y;
        }
      };
    }();
  }, {} ],
  2: [ function(require, module, exports) {
    !function() {
      var S = document.createElement("style");
      S.innerHTML = "body::before {  }\nbody {  }";
      document.head.appendChild(S);
      var rule0 = S.sheet.cssRules[0], rule1 = S.sheet.cssRules[1];
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule0.style.content = JSON.stringify("" + function() {
            return (window._funcss_mousePointer || (window._funcss_mousePointer = require("mouse-pointer"))).pageMouseX();
          }()) + ' "," ' + JSON.stringify("" + function() {
            return (window._funcss_mousePointer || (window._funcss_mousePointer = require("mouse-pointer"))).pageMouseY();
          }());
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule1.style.backgroundColor = function() {
            var c = function(x, y0, x0, y1, x1) {
              return {
                r: y0.r + x * (y1.r - y0.r) / (x1 - x0),
                g: y0.g + x * (y1.g - y0.g) / (x1 - x0),
                b: y0.b + x * (y1.b - y0.b) / (x1 - x0)
              };
            }(function() {
              return (window._funcss_mousePointer || (window._funcss_mousePointer = require("mouse-pointer"))).pageMouseX();
            }(), {
              r: 255,
              g: 0,
              b: 0
            }, 0, {
              r: 255,
              g: 255,
              b: 0
            }, 1e3);
            return c.a || 0 === c.a ? "rgba(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + "," + Math.round(c.a) + ")" : "rgb(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + ")";
          }();
        });
      });
    }();
  }, {
    "mouse-pointer": 1
  } ]
}, {}, [ 2 ]);