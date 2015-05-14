// Generated by CoffeeScript 1.9.1
(function() {
  var Generator, Semantics, Syntax;

  Syntax = require("./syntax");

  Semantics = require("./semantics");

  Generator = require("./generator");

  exports.compile = function(str) {
    var fs, ig, ss;
    ss = Syntax(str);
    fs = Semantics(ss);
    ig = Generator(fs);
    return ig.toString();
  };

}).call(this);