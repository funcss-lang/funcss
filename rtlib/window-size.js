!function() {

var pageRect = function() {
    var active = false;
    var rv = new ReactiveVar;
    var activeDependentsById = {};
    var handler = function(event) {
        for (var id in activeDependentsById) {
            rv.set(document.documentElement.getBoundingClientRect());
            return;
        }
        window.removeEventListener("resize", handler, false);
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
            window.addEventListener("resize", handler, false);
            active = true;
            rv.set(document.documentElement.getBoundingClientRect());
        }
        return rv.get();
    };
}();

window.setTimeout(pageRect(),100);

module.exports = {
  pageWidth: function() {return pageRect().width},
  pageHeight: function() {return pageRect().height}
}

}();
