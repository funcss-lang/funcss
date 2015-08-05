!function() {

var mouseWheelDelta = function() {
    var active = false;
    var rv = new ReactiveVar;
    var activeDependentsById = {};
    var handler = function(event) {
      // http://www.sitepoint.com/html5-javascript-mouse-wheel/
      rv.set(rv.get() + Math.max(-1, Math.min(1, (event.wheelDelta || -event.detail))));
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
            document.addEventListener("mousewheel", handler, false);
            document.addEventListener("DOMMouseScroll", handler, false);
            active = true;
            rv.set(0);
        }
        return rv.get();
    };
}();

module.exports = {
  mouseWheelDelta: mouseWheelDelta,
}

}();

