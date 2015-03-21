!function(){
var S = document.createElement("style"), rule0s, startTime;
S.innerHTML="body  {  margin-left: 0;  }";
document.head.appendChild(S);
rule0s = S.sheet.cssRules[0].style;
t = function() {
    var interval, startTime = new Date, dep = new Tracker.Dependency;
    function t() {
        if (!interval) {
            interval = setInterval(function(){ dep.changed(); }, 0);
        }
        dep.depend();
        return ((new Date)-startTime)/1000;
    }
    return t;
}();
Tracker.autorun(function() {
    rule0s.marginLeft = t()+"px";
});
}();
