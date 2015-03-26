!function() {

/**
 *
 */
var EventReporter = function(addListener, removeListener) {
    if (!(this instanceof EventReporter))
        return new EventReporter(addListener, removeListener);
    this.addListener = addListener;
    this.removeListener = removeListener;
    this.dep = new Tracke.Dependency;
};


EventReporter.prototype.

window.EventReporter = EventReporter;

}();
