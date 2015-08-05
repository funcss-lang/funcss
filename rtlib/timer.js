!function() {

var timer = function() {
    var active = false;
    var rv = new ReactiveVar;
    var activeDependentsById = {};
    var SAMPLE_RATE = 13;
    var handler = function(event) {
        for (var id in activeDependentsById) {
            rv.set(new Date());
            window.setTimeout(handler, SAMPLE_RATE)
            return;
        }
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
            window.setTimeout(handler, SAMPLE_RATE);
            active = true;
            rv.set(new Date());
        }
        return rv.get();
    };
}();

load = +new Date();
module.exports = {
  get: timer,
  getTimeSinceLoad: function() {
    return timer()-load;
  }
};

}();

