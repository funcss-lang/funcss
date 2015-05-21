(function(){

var S = document.createElement("style");
S.innerHTML="body p {  }";
document.head.appendChild(S);
var rule0 = S.sheet.cssRules[0];
window.addEventListener("load", function() {
  Tracker.autorun(function() {
  rule0.style["color"] = 'rgb('+"255"+','+"0"+','+"0"+')';
});
});
})();