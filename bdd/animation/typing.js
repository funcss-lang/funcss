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
      var timer = function() {
        var active = !1, rv = new ReactiveVar(), activeDependentsById = {}, SAMPLE_RATE = 13, handler = function(event) {
          for (var id in activeDependentsById) {
            rv.set(new Date());
            window.setTimeout(handler, SAMPLE_RATE);
            return;
          }
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
            window.setTimeout(handler, SAMPLE_RATE);
            active = !0;
            rv.set(new Date());
          }
          return rv.get();
        };
      }();
      load = +new Date();
      module.exports = {
        get: timer,
        getTimeSinceLoad: function() {
          return timer() - load;
        }
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
          rule0.style.content = JSON.stringify("" + function(s, start, end) {
            return s.substring(start - 1, end);
          }("Lorem ipsum dolor sit amet consectetur adepiscing elit. ", 1, function(x) {
            return Math.round(x);
          }(function(x, y1, x1) {
            return x * y1 / x1;
          }(function() {
            return (window._funcss_timer || (window._funcss_timer = require("timer"))).getTimeSinceLoad();
          }(), 12, 1e3)))) + ' "_"';
        });
      });
    }();
  }, {
    timer: 1
  } ]
}, {}, [ 2 ]);