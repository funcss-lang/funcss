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
      var mouseWheelDelta = function() {
        var active = !1, rv = new ReactiveVar(), activeDependentsById = {}, handler = function(event) {
          rv.set(rv.get() + Math.max(-1, Math.min(1, event.wheelDelta || -event.detail)));
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
            document.addEventListener("mousewheel", handler, !1);
            document.addEventListener("DOMMouseScroll", handler, !1);
            active = !0;
            rv.set(0);
          }
          return rv.get();
        };
      }();
      module.exports = {
        mouseWheelDelta: mouseWheelDelta
      };
    }();
  }, {} ],
  2: [ function(require, module, exports) {
    !function() {
      var S = document.createElement("style");
      S.innerHTML = "body::before {  }";
      document.head.appendChild(S);
      var rule0 = S.sheet.cssRules[0];
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule0.style.content = JSON.stringify("" + function(x) {
            return x;
          }(function() {
            return (window._funcss_mouseWheel || (window._funcss_mouseWheel = require("mouse-wheel"))).mouseWheelDelta();
          }()));
        });
      });
    }();
  }, {
    "mouse-wheel": 1
  } ]
}, {}, [ 2 ]);