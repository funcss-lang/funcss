// Generated by CoffeeScript 1.9.1
(function() {
  module.exports = function(fn) {
    var walkChild;
    return walkChild = function(node) {
      var action, i, ref;
      if (node instanceof Array) {
        i = 0;
        while (i < node.length) {
          action = (ref = fn.apply(node[i])) != null ? ref : {};
          if (action.remove) {
            node.splice(i, 1);
          } else if (!action.skip) {
            walkChild(node[i]);
            ++i;
          } else {
            ++i;
          }
        }
      } else if (node.value != null) {
        walkChild(node.value);
      }
      return node;
    };
  };

}).call(this);