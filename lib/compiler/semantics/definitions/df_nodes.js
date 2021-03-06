// Generated by CoffeeScript 1.9.1
(function() {
  var DF, ER, FS, GR, SS, Snd, VL, assert,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ER = require("../../errors/er_nodes");

  SS = require("../../syntax/ss_nodes");

  GR = require("../../syntax/gr_nodes");

  assert = require("../../helpers/assert");

  FS = require("../fs_nodes");

  VL = require("../values/vl_nodes");

  DF = exports;

  Snd = function(_, y) {
    return y;
  };

  DF.Definable = (function() {
    function Definable() {}

    return Definable;

  })();

  DF.VariableName = (function(superClass) {
    extend(VariableName, superClass);

    function VariableName(value1) {
      this.value = value1;
    }

    VariableName.prototype.grammar = function(semantic) {
      if (this.value.charAt(0) === "$") {
        return new GR.CloselyJuxtaposed(new GR.DelimLike(new SS.DelimToken('$')), new GR.Keyword(this.value.substr(1)), semantic);
      } else {
        return new GR.Keyword(this.value, semantic);
      }
    };

    VariableName.prototype.toString = function() {
      return this.value;
    };

    return VariableName;

  })(DF.Definable);

  DF.FunctionalNotation = (function(superClass) {
    extend(FunctionalNotation, superClass);

    function FunctionalNotation(name, argument1) {
      this.name = name;
      this.argument = argument1;
    }

    FunctionalNotation.prototype.grammar = function(semantic) {
      return new GR.FunctionalNotation(this.name, this.argument, semantic);
    };

    FunctionalNotation.prototype.toString = function() {
      return this.name + "(" + this.argument + ")";
    };

    return FunctionalNotation;

  })(DF.Definable);

  DF.Definition = (function() {
    function Definition(definable, typeName, rawValue, block) {
      this.definable = definable;
      this.typeName = typeName;
      this.rawValue = rawValue;
      this.block = block;
    }

    Definition.prototype.grammar = function(fs) {
      var gr, type, value;
      if (console.debug) {
        console.debug("defining " + this);
      }
      assert.instanceOf({
        fs: fs
      }, FS.FunctionalStylesheet);
      if (this.definable instanceof DF.VariableName) {
        if (this.typeName == null) {
          throw new ER.TypeInferenceNotImplemented(this.definable);
        }
        type = fs.getType(this.typeName);
        if (type == null) {
          throw new ER.UnknownType(this.typeName);
        }
        if (this.rawValue != null) {
          value = type.parse(this.rawValue);
          gr = this.definable.grammar(function() {
            return value;
          });
        } else if (this.block) {
          if (type.decodejs == null) {
            throw new ER.DecodingNotSupported(type);
          }
          value = new VL.JavaScriptFunction(type, new VL.Marking(new VL.EmptyValue, {}), this.block);
          gr = this.definable.grammar(function() {
            return value;
          });
        } else {
          throw new ER.SyntaxError("Definition does not have a body. Please add `= someValue` or `{ return someValue }`");
        }
      } else if (this.definable instanceof DF.FunctionalNotation) {
        if (this.typeName == null) {
          throw new ER.TypeInferenceNotImplemented(this.definable);
        }
        type = fs.getType(this.typeName);
        if (type == null) {
          throw new ER.UnknownType(this.typeName);
        }
        if ((this.rawValue == null) && (this.block == null)) {
          throw new ER.SyntaxError("Definition does not have a body. Please add `= someValue` or `{ return someValue }`");
        }
        gr = this.definable.grammar((function(_this) {
          return function(argument) {
            var k, ref, v;
            if (!(argument instanceof VL.Marking)) {
              argument = new VL.Marking(argument, {});
            }
            if (console.debug) {
              console.debug("parsed " + (_this.definable.grammar(function() {})) + " with argument " + argument);
            }
            if (_this.rawValue != null) {
              fs.pushScope();
              try {
                ref = argument.marking;
                for (k in ref) {
                  v = ref[k];
                  fs.setType('number', new GR.Keyword(k, function() {
                    return v;
                  }));
                }
                value = type.parse(_this.rawValue);
              } finally {
                fs.popScope();
              }
              return value;
            } else if (_this.block != null) {
              if (type.decodejs == null) {
                throw new ER.DecodingNotSupported(type);
              }
              return new VL.JavaScriptFunction(type, argument, _this.block);
            } else {
              throw new Error("Internal Error in FunCSS");
            }
          };
        })(this));
      } else {
        throw new Error("Internal Error in FunCSS: unknown definable type");
      }
      gr.setFs(fs);
      return gr;
    };

    Definition.prototype.toString = function() {
      return "" + this.definable + (this.typeName ? ":" + this.typeName : "") + (this.rawValue ? " = " + this.rawValue : "") + (this.block ? " " + this.block : "");
    };

    return Definition;

  })();

}).call(this);
