!function(){
var S = document.createElement("style");
S.innerHTML="body { }";
document.head.appendChild(S);
var rule0 = S.sheet.cssRules[0];
var pageMouseX = function() {
    var listener = null;
    var rv = new ReactiveVar;
    return function(){
        if (!listener) {
            listener = function(evt) {
                if (!rv.dep.hasDependents()) {
                    document.body.removeEventListener("mousemove", listener, false);
                    listener = null;
                } else {
                    rv.set(evt.pageX);
                }
            };
            document.body.addEventListener("mousemove", listener, false);
            rv.set(0);
        }
        return rv.get();
    };
}();
function rgb(r,g,b) {
    return "rgb("+r+","+g+","+b+")"
}
window.addEventListener("load", function() {
    Tracker.autorun(function() { rule0.style.backgroundColor = rgb(255, pageMouseX(), pageMouseX()); });
}, false);
}()
