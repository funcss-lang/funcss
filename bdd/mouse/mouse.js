(function(){
var S = document.createElement("style");
S.innerHTML="body { }";
document.head.appendChild(S);
var rule0 = S.sheet.cssRules[0];
var pageMouseX = function() {
    var active = false;
    var rv = new ReactiveVar;
    var activeDependentsById = {};
    var handler = function(event) {
        for (var id in activeDependentsById) {
            rv.set(event.pageX);
            return;
        }
        document.removeEventListener("mousemove", handler, false);
        active = false;
    };
    return function(){
        var computation = Tracker.currentComputation;
        if (computation && !(computation._id in activeDependentsById)) {
            activeDependentsById[computation._id] = computation;
            computation.onInvalidate(function() {
                if (computation.stopped) {
                    delete activeDependentsById[computation._id];
                }
            })
        }
        if (!active) {
            document.addEventListener("mousemove", handler, false);
            active = true;
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
})();
