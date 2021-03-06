// Generated by CoffeeScript 1.9.1
(function() {
  var Cascade, FS, GR, IG, SS;

  SS = require("../../syntax/ss_nodes");

  GR = require("../../syntax/gr_nodes");

  FS = require("../fs_nodes");

  IG = require("../../generator/ig_nodes");

  module.exports = Cascade = (function() {
    function Cascade(fs) {
      this.fs = fs;
      this.simpleRules = [];
    }

    Cascade.prototype.consume_declaration = function(sel, decl) {
      var type, value;
      type = this.fs.getPropertyType(decl.name);
      type.setFs(this.fs);
      value = type.parse(decl.value);
            if (value != null) {
        value;
      } else {
        throw new Error("Internal error in FunCSS: type " + type + " did not return a value");
      };
      this.simpleRules.push(new FS.SimpleRule({
        mediaQuery: null,
        selector: sel,
        name: decl.name,
        value: type.parse(decl.value),
        important: decl.important
      }));
    };

    Cascade.prototype.puppetRules = function() {
      var index, pr, sr;
      return this._puppetRules != null ? this._puppetRules : this._puppetRules = (function() {
        var i, len, ref, results;
        ref = this.simpleRules;
        results = [];
        for (index = i = 0, len = ref.length; i < len; index = ++i) {
          sr = ref[index];
          pr = new SS.QualifiedRule(sr.selector);
          pr.index = index;
          sr.puppetRule = pr;
          results.push(pr);
        }
        return results;
      }).call(this);
    };

    Cascade.prototype.puppetStylesheet = function() {
      return this._puppetStylesheet != null ? this._puppetStylesheet : this._puppetStylesheet = new SS.Stylesheet(this.puppetRules());
    };

    Cascade.prototype.ig = function() {
      var i, ig, j, len, len1, pss, ref, ref1, sr;
      ig = new IG.Sequence;
      ig.push(pss = new IG.CssStylesheet(this.puppetStylesheet()));
      ref = this.simpleRules;
      for (i = 0, len = ref.length; i < len; i++) {
        sr = ref[i];
        ig.push(new IG.Rule(pss, sr.puppetRule.index));
      }
      ref1 = this.simpleRules;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        sr = ref1[j];
        ig.push(new IG.DomReady(new IG.Autorun(new IG.SetDeclarationValue(sr.puppetRule.index, sr.name, sr.value))));
      }
      return ig;
    };

    return Cascade;

  })();

}).call(this);
