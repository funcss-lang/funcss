!function() {

var pageMouseXY = function() {
    var active = false;
    var rv = new ReactiveVar;
    var activeDependentsById = {};
    var handler = function(event) {
        for (var id in activeDependentsById) {
            rv.set({x:event.pageX,y:event.pageY});
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
            rv.set({x:0,y:0});
        }
        return rv.get();
    };
}();

module.exports = {
  pageMouseX: function() {return pageMouseXY().x},
  pageMouseY: function() {return pageMouseXY().y}
}

}();
