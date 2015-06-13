!function() {
  var S = document.createElement("style");
  S.innerHTML = ".clock>.second-hand {  }\n.clock>.minute-hand {  }\n.clock>.hour-hand {  }";
  document.head.appendChild(S);
  var rule0 = S.sheet.cssRules[0], rule1 = S.sheet.cssRules[1], rule2 = S.sheet.cssRules[2];
  window.addEventListener("load", function() {
    Tracker.autorun(function() {
      rule0.style.transform = "rotate(" + 6.283185307179586 * function() {
        return (window._funcss_timer || (window._funcss_timer = require("timer")))().getSeconds();
      }() / 60 + "rad)";
    });
  });
  window.addEventListener("load", function() {
    Tracker.autorun(function() {
      rule1.style.transform = "rotate(" + 6.283185307179586 * function() {
        return (window._funcss_timer || (window._funcss_timer = require("timer")))().getMinutes();
      }() / 60 + "rad)";
    });
  });
  window.addEventListener("load", function() {
    Tracker.autorun(function() {
      rule2.style.transform = "rotate(" + 6.283185307179586 * function() {
        return (window._funcss_timer || (window._funcss_timer = require("timer")))().getHours();
      }() / 12 + "rad)";
    });
  });
}();