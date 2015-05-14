// Generated by CoffeeScript 1.9.1
(function() {
  var GR, VL;

  GR = require("../../syntax/gr_nodes");

  VL = require("./vl_nodes");

  exports.primitiveTypes = {
    ident: new GR.Ident(function(x) {
      return new VL.Keyword(x.value);
    }),
    number: new GR.Number(function(x) {
      return new VL.Number(x.value);
    }),
    integer: new GR.Integer(function(x) {
      return new VL.Number(x.value);
    }),
    percentage: new GR.Percentage(function(x) {
      return new VL.Percentage(x.value);
    }),
    string: new GR.String(function(x) {
      return new VL.String(x.value);
    })
  };

  exports.dimensions = {
    length: {
      px: "TODO"
    }
  };

}).call(this);