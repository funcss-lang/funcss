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
              x: NaN,
              y: NaN
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
        }
      };
    }();
  }, {} ],
  3: [ function(require, module, exports) {
    !function() {
      var S = document.createElement("style");
      document.getElementsByTagName("head")[0].appendChild(S);
      var S_content = "body::before {  }\nhtml {  }\nhtml {  }";
      S.sheet ? S.innerHTML = S_content : S.styleSheet.cssText = S_content;
      var rule0 = S.sheet ? S.sheet.cssRules[0] : S.styleSheet.rules[0], rule1 = S.sheet ? S.sheet.cssRules[1] : S.styleSheet.rules[1], rule2 = S.sheet ? S.sheet.cssRules[2] : S.styleSheet.rules[2];
      !function() {
        function ready() {
          if (!_funcss_dom_loaded) {
            _funcss_dom_loaded = !0;
            Tracker.autorun(function() {
              rule0.style.content = JSON.stringify("" + function() {
                return (window._funcss_windowSize || (window._funcss_windowSize = require("window-size"))).pageHeight();
              }());
            });
            Tracker.autorun(function() {
              rule1.style.height = "100%";
            });
            Tracker.autorun(function() {
              rule2.style.background = function() {
                var c = function(h, s, l) {
                  function hue2rgb(m1, m2, h) {
                    0 > h && (h += 1);
                    h > 1 && (h -= 1);
                    return 1 > 6 * h ? m1 + (m2 - m1) * h * 6 : 1 > 2 * h ? m2 : 2 > 3 * h ? m1 + (m2 - m1) * (2 / 3 - h) * 6 : m1;
                  }
                  var m1, m2;
                  m2 = .5 >= l ? l * (s + 1) : l + s - l * s;
                  m1 = 2 * l - m2;
                  return {
                    r: 255 * hue2rgb(m1, m2, h + 1 / 3),
                    g: 255 * hue2rgb(m1, m2, h),
                    b: 255 * hue2rgb(m1, m2, h - 1 / 3)
                  };
                }(1 * function(y, x) {
                  return Math.atan2(y, x);
                }(function() {
                  return (window._funcss_mousePointer || (window._funcss_mousePointer = require("mouse-pointer"))).pageMouseX();
                }(), function() {
                  return (window._funcss_mousePointer || (window._funcss_mousePointer = require("mouse-pointer"))).pageMouseY();
                }()) / 1.5707963267948966, 1 * Math.sqrt(function() {
                  return (window._funcss_mousePointer || (window._funcss_mousePointer = require("mouse-pointer"))).pageMouseX();
                }() * function() {
                  return (window._funcss_mousePointer || (window._funcss_mousePointer = require("mouse-pointer"))).pageMouseX();
                }() + function() {
                  return (window._funcss_mousePointer || (window._funcss_mousePointer = require("mouse-pointer"))).pageMouseY();
                }() * function() {
                  return (window._funcss_mousePointer || (window._funcss_mousePointer = require("mouse-pointer"))).pageMouseY();
                }()) / function(x) {
                  return Math.min.apply(Math, x);
                }([ function() {
                  return (window._funcss_windowSize || (window._funcss_windowSize = require("window-size"))).pageWidth();
                }(), function() {
                  return (window._funcss_windowSize || (window._funcss_windowSize = require("window-size"))).pageHeight();
                }() ]), .5);
                return c.a || 0 === c.a ? "rgba(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + "," + Math.round(c.a) + ")" : "rgb(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + ")";
              }();
            });
          }
        }
        var _funcss_dom_loaded = !1;
        (document.addEventListener || document.attachEvent)("DOMContentLoaded", ready);
        (document.addEventListener || document.attachEvent)("readystatechange", ready);
      }();
    }();
  }, {
    "mouse-pointer": 1,
    "window-size": 2
  } ]
}, {}, [ 3 ]);