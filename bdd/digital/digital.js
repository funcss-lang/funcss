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
      S.innerHTML = "body {  }\n.segment {  }\n.segment {  }\n.horz {  }\n.horz {  }\n.horz {  }\n.horz {  }\n.horz {  }\n.vert {  }\n.vert {  }\n.vert {  }\n.vert {  }\n#s2,#s5 {  }\n#s1 {  }\n#s2 {  }\n#s3 {  }\n#s4 {  }\n#s5 {  }\n#s6 {  }\n#s7 {  }";
      document.head.appendChild(S);
      var rule0 = S.sheet.cssRules[0], rule1 = S.sheet.cssRules[1], rule2 = S.sheet.cssRules[2], rule3 = S.sheet.cssRules[3], rule4 = S.sheet.cssRules[4], rule5 = S.sheet.cssRules[5], rule6 = S.sheet.cssRules[6], rule7 = S.sheet.cssRules[7], rule8 = S.sheet.cssRules[8], rule9 = S.sheet.cssRules[9], rule10 = S.sheet.cssRules[10], rule11 = S.sheet.cssRules[11], rule12 = S.sheet.cssRules[12], rule13 = S.sheet.cssRules[13], rule14 = S.sheet.cssRules[14], rule15 = S.sheet.cssRules[15], rule16 = S.sheet.cssRules[16], rule17 = S.sheet.cssRules[17], rule18 = S.sheet.cssRules[18], rule19 = S.sheet.cssRules[19];
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule0.style.backgroundColor = "rgb(" + Math.round("0") + "," + Math.round("0") + "," + Math.round("0") + ")";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule1.style.display = "block";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule2.style["float"] = "left";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule3.style.margin = "5px 10px";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule4.style.clear = "left";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule5.style.height = "5px";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule6.style.width = "100px";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule7.style.borderTop = "5px solid";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule8.style.width = "5px";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule9.style.height = "100px";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule10.style.borderLeft = "5px solid";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule11.style.marginRight = "100px";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule12.style.clear = "left";
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule13.style.borderColor = function() {
            var c = function($x, $y0, $a) {
              for (var s = 0, e = $a.length, p = Math.floor(e / 2); p != s; ) {
                $x < $a[p].xi ? e = p : s = p;
                p = s + Math.floor((e - s) / 2);
              }
              return $x < $a[p].xi ? 0 == p ? $y0 : $a[p - 1].yi : $a[p].yi;
            }(function($x, $from, $to) {
              var $l = $to - $from;
              return $from + (($x - $from) % $l + $l) % $l;
            }(function(x, modulus) {
              return Math.round(x / modulus) * modulus;
            }(function() {
              return (window._funcss_timer || (window._funcss_timer = require("timer"))).get().getSeconds();
            }(), 1), 0, 10), {
              r: 136,
              g: 0,
              b: 0
            }, [ {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 1
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 2
            }, {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 4
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 5
            } ]);
            return c.a || 0 === c.a ? "rgba(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + "," + Math.round(c.a) + ")" : "rgb(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + ")";
          }();
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule14.style.borderColor = function() {
            var c = function($x, $y0, $a) {
              for (var s = 0, e = $a.length, p = Math.floor(e / 2); p != s; ) {
                $x < $a[p].xi ? e = p : s = p;
                p = s + Math.floor((e - s) / 2);
              }
              return $x < $a[p].xi ? 0 == p ? $y0 : $a[p - 1].yi : $a[p].yi;
            }(function($x, $from, $to) {
              var $l = $to - $from;
              return $from + (($x - $from) % $l + $l) % $l;
            }(function(x, modulus) {
              return Math.round(x / modulus) * modulus;
            }(function() {
              return (window._funcss_timer || (window._funcss_timer = require("timer"))).get().getSeconds();
            }(), 1), 0, 10), {
              r: 136,
              g: 0,
              b: 0
            }, [ {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 1
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 4
            }, {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 7
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 8
            } ]);
            return c.a || 0 === c.a ? "rgba(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + "," + Math.round(c.a) + ")" : "rgb(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + ")";
          }();
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule15.style.borderColor = function() {
            var c = function($x, $y0, $a) {
              for (var s = 0, e = $a.length, p = Math.floor(e / 2); p != s; ) {
                $x < $a[p].xi ? e = p : s = p;
                p = s + Math.floor((e - s) / 2);
              }
              return $x < $a[p].xi ? 0 == p ? $y0 : $a[p - 1].yi : $a[p].yi;
            }(function($x, $from, $to) {
              var $l = $to - $from;
              return $from + (($x - $from) % $l + $l) % $l;
            }(function(x, modulus) {
              return Math.round(x / modulus) * modulus;
            }(function() {
              return (window._funcss_timer || (window._funcss_timer = require("timer"))).get().getSeconds();
            }(), 1), 0, 10), {
              r: 136,
              g: 0,
              b: 0
            }, [ {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 5
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 7
            } ]);
            return c.a || 0 === c.a ? "rgba(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + "," + Math.round(c.a) + ")" : "rgb(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + ")";
          }();
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule16.style.borderColor = function() {
            var c = function($x, $y0, $a) {
              for (var s = 0, e = $a.length, p = Math.floor(e / 2); p != s; ) {
                $x < $a[p].xi ? e = p : s = p;
                p = s + Math.floor((e - s) / 2);
              }
              return $x < $a[p].xi ? 0 == p ? $y0 : $a[p - 1].yi : $a[p].yi;
            }(function($x, $from, $to) {
              var $l = $to - $from;
              return $from + (($x - $from) % $l + $l) % $l;
            }(function(x, modulus) {
              return Math.round(x / modulus) * modulus;
            }(function() {
              return (window._funcss_timer || (window._funcss_timer = require("timer"))).get().getSeconds();
            }(), 1), 0, 10), {
              r: 0,
              g: 0,
              b: 0
            }, [ {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 2
            }, {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 7
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 8
            } ]);
            return c.a || 0 === c.a ? "rgba(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + "," + Math.round(c.a) + ")" : "rgb(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + ")";
          }();
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule17.style.borderColor = function() {
            var c = function($x, $y0, $a) {
              for (var s = 0, e = $a.length, p = Math.floor(e / 2); p != s; ) {
                $x < $a[p].xi ? e = p : s = p;
                p = s + Math.floor((e - s) / 2);
              }
              return $x < $a[p].xi ? 0 == p ? $y0 : $a[p - 1].yi : $a[p].yi;
            }(function($x, $from, $to) {
              var $l = $to - $from;
              return $from + (($x - $from) % $l + $l) % $l;
            }(function(x, modulus) {
              return Math.round(x / modulus) * modulus;
            }(function() {
              return (window._funcss_timer || (window._funcss_timer = require("timer"))).get().getSeconds();
            }(), 1), 0, 10), {
              r: 136,
              g: 0,
              b: 0
            }, [ {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 1
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 2
            }, {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 3
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 6
            }, {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 7
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 8
            }, {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 9
            } ]);
            return c.a || 0 === c.a ? "rgba(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + "," + Math.round(c.a) + ")" : "rgb(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + ")";
          }();
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule18.style.borderColor = function() {
            var c = function($x, $y0, $a) {
              for (var s = 0, e = $a.length, p = Math.floor(e / 2); p != s; ) {
                $x < $a[p].xi ? e = p : s = p;
                p = s + Math.floor((e - s) / 2);
              }
              return $x < $a[p].xi ? 0 == p ? $y0 : $a[p - 1].yi : $a[p].yi;
            }(function($x, $from, $to) {
              var $l = $to - $from;
              return $from + (($x - $from) % $l + $l) % $l;
            }(function(x, modulus) {
              return Math.round(x / modulus) * modulus;
            }(function() {
              return (window._funcss_timer || (window._funcss_timer = require("timer"))).get().getSeconds();
            }(), 1), 0, 10), {
              r: 136,
              g: 0,
              b: 0
            }, [ {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 2
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 3
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 4
            } ]);
            return c.a || 0 === c.a ? "rgba(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + "," + Math.round(c.a) + ")" : "rgb(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + ")";
          }();
        });
      });
      window.addEventListener("load", function() {
        Tracker.autorun(function() {
          rule19.style.borderColor = function() {
            var c = function($x, $y0, $a) {
              for (var s = 0, e = $a.length, p = Math.floor(e / 2); p != s; ) {
                $x < $a[p].xi ? e = p : s = p;
                p = s + Math.floor((e - s) / 2);
              }
              return $x < $a[p].xi ? 0 == p ? $y0 : $a[p - 1].yi : $a[p].yi;
            }(function($x, $from, $to) {
              var $l = $to - $from;
              return $from + (($x - $from) % $l + $l) % $l;
            }(function(x, modulus) {
              return Math.round(x / modulus) * modulus;
            }(function() {
              return (window._funcss_timer || (window._funcss_timer = require("timer"))).get().getSeconds();
            }(), 1), 0, 10), {
              r: 136,
              g: 0,
              b: 0
            }, [ {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 1
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 2
            }, {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 4
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 5
            }, {
              yi: {
                r: 0,
                g: 0,
                b: 0
              },
              xi: 7
            }, {
              yi: {
                r: 136,
                g: 0,
                b: 0
              },
              xi: 8
            } ]);
            return c.a || 0 === c.a ? "rgba(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + "," + Math.round(c.a) + ")" : "rgb(" + Math.round(c.r) + "," + Math.round(c.g) + "," + Math.round(c.b) + ")";
          }();
        });
      });
    }();
  }, {
    timer: 1
  } ]
}, {}, [ 2 ]);