// Generated by CoffeeScript 1.9.1
(function() {
  var AddMarkings, Ampersand, And, Annotation, Asterisk, Atom, Bar, Bracket, Bracketable, Bracketed, ClosingAngle, ClosingCurly, ClosingSquare, Colon, Column, Combined, Comma, ComponentValue, Cons, DblAmpersand, Dollar, ExclusiveOr, Fst, FunctionalNotation, GR, Hashmark, Id, Ident, InclusiveOr, Integer, Juxtaposition, Keyword, LiteralComma, LiteralSlash, Multipliable, Multiplied, Multiplier, Number, OpeningAngle, OpeningCurly, OpeningSquare, OptionalRoot, PLACEHOLDER, Pair, Percentage, Plus, QuestionMark, RepeatCount, Root, SS, Snd, String, TypeReference, VL, Variable, Vds, isEmptyObject, k, pairsOf, ref, v,
    slice = [].slice;

  GR = require("../../syntax/gr_nodes");

  SS = require("../../syntax/ss_nodes");

  VL = require("./vl_nodes");

  Id = Fst = function(x) {
    return x;
  };

  Snd = function(_, y) {
    return y;
  };

  Pair = function(x, y) {
    return [x, y];
  };

  Cons = function(x, y) {
    y.unshift(x);
    return y;
  };

  pairsOf = function(t, list, opts) {
    if (opts == null) {
      opts = {};
    }
    if (!list.length) {
      throw new Error("internal error in VDS: cannot make pairs of empty list or a non-list");
    }
    if (list.length === 1) {
      return list[0];
    }
    if (list.length === 2) {
      return new t(list[0], list[1], opts.pair);
    }
    return new t(list[0], pairsOf(t, list.slice(1), opts), opts.cons);
  };

  OpeningAngle = new GR.DelimLike(new SS.DelimToken('<'));

  ClosingAngle = new GR.DelimLike(new SS.DelimToken('>'));

  OpeningCurly = new GR.DelimLike(new SS.OpeningCurlyToken);

  ClosingCurly = new GR.DelimLike(new SS.ClosingCurlyToken);

  OpeningSquare = new GR.DelimLike(new SS.OpeningSquareToken);

  ClosingSquare = new GR.DelimLike(new SS.ClosingSquareToken);

  Colon = new GR.DelimLike(new SS.ColonToken);

  Ampersand = new GR.DelimLike(new SS.DelimToken('&'));

  DblAmpersand = new GR.CloselyJuxtaposed(Ampersand, Ampersand, function() {});

  Column = new GR.DelimLike(new SS.ColumnToken);

  Bar = new GR.DelimLike(new SS.DelimToken('|'));

  Comma = new GR.DelimLike(new SS.CommaToken);

  Dollar = new GR.DelimLike(new SS.DelimToken('$'));

  PLACEHOLDER = {
    parse: function() {
      throw new Error("PLACEHOLDER not replaced");
    }
  };

  Ident = new GR.Ident;

  Number = new GR.Number;

  Integer = new GR.Integer;

  Percentage = new GR.Percentage;

  String = new GR.String;

  AddMarkings = function(x, markings) {
    if (markings && !isEmptyObject(markings)) {
      return new VL.Marking(x, markings);
    } else {
      return x;
    }
  };

  LiteralSlash = new GR.DelimLike(new SS.DelimToken('/'), function(x) {
    return new GR.DelimLike(x, function(x) {
      return new VL.Keyword("/");
    });
  });

  LiteralComma = new GR.DelimLike(new SS.CommaToken, function(x) {
    return new GR.DelimLike(x, function(x) {
      return new VL.Keyword(",");
    });
  });

  Hashmark = new GR.DelimLike(new SS.DelimToken('#'), function() {
    return {
      collection: VL.CommaDelimitedCollection,
      multiplier: GR.DelimitedByComma
    };
  });

  Plus = new GR.DelimLike(new SS.DelimToken('+'), function() {
    return {
      collection: VL.Collection,
      multiplier: GR.OneOrMore
    };
  });

  QuestionMark = new GR.DelimLike(new SS.DelimToken('?'), function() {
    return {
      collection: false,
      multiplier: GR.Optional
    };
  });

  Asterisk = new GR.DelimLike(new SS.DelimToken('*'), function() {
    return {
      collection: VL.Collection,
      multiplier: GR.ZeroOrMore
    };
  });

  RepeatCount = new GR.SimpleBlock(SS.OpeningCurlyToken, new GR.CloselyJuxtaposed(Integer, new GR.CloselyJuxtaposed(Comma, Integer, Snd), Pair), function(arg) {
    var from, to;
    from = arg[0], to = arg[1];
    return {
      collection: VL.Collection,
      multiplier: GR.Range,
      args: [from, to]
    };
  });

  Keyword = new GR.Ident(function(x) {
    return new GR.Keyword(x.value, function(x) {
      return new VL.Keyword(x.value);
    });
  });

  TypeReference = new GR.Juxtaposition(OpeningAngle, new GR.Juxtaposition(new GR.ExclusiveOr(new GR.Ident(function(x) {
    return [x.value, false];
  }), new GR.String(function(x) {
    return [x.value, true];
  })), ClosingAngle, Fst), function(_, arg) {
    var name, quoted;
    name = arg[0], quoted = arg[1];
    return new GR.TypeReference(name, quoted);
  });

  FunctionalNotation = new GR.AnyFunctionalNotation(PLACEHOLDER, function(name, x) {
    return new GR.FunctionalNotation(name, x, function(y) {
      return new VL.FunctionalNotation(name, y);
    });
  });

  Variable = new GR.ExclusiveOr(new GR.CloselyJuxtaposed(Dollar, Ident, function(x, y) {
    return x + y;
  }), Ident);

  Variable.expected = "variable";

  Annotation = new GR.Juxtaposition(Variable, new GR.Juxtaposition(Colon, new GR.ExclusiveOr(new GR.Ident(function(x) {
    return new GR.TypeReference(x.value);
  }), PLACEHOLDER), Snd), function(name, a) {
    return new GR.Annotation(name, a, AddMarkings);
  });

  ComponentValue = pairsOf(GR.ExclusiveOr, [TypeReference, Annotation, Keyword, FunctionalNotation, LiteralSlash, LiteralComma]);

  Bracketable = ComponentValue;

  Bracket = new GR.SimpleBlock(SS.OpeningSquareToken, PLACEHOLDER);

  Bracketed = new GR.ExclusiveOr(Bracketable, Bracket);

  Annotation.b.b.b = Bracket;

  Multipliable = Bracketed;

  Multiplier = pairsOf(GR.ExclusiveOr, [Asterisk, Plus, QuestionMark, RepeatCount, Hashmark], {
    pair: Id,
    cons: Id
  });

  Multiplied = new GR.Juxtaposition(Multipliable, new GR.Optional(Multiplier), function(a, multdata) {
    var ref, ref1;
    if (multdata) {
      if (multdata.collection) {
        return (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args);
          return Object(result) === result ? result : child;
        })(multdata.multiplier, slice.call((ref = multdata.args) != null ? ref : []).concat([new GR.AnnotationRoot(a, AddMarkings)], [function(arr) {
          return new multdata.collection(arr);
        }]), function(){});
      } else {
        return (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args);
          return Object(result) === result ? result : child;
        })(multdata.multiplier, slice.call((ref1 = multdata.args) != null ? ref1 : []).concat([new GR.AnnotationRoot(a, AddMarkings)], [function(x) {
          return x != null ? x : new VL.EmptyValue;
        }]), function(){});
      }
    } else {
      return a;
    }
  });

  isEmptyObject = function(x) {
    var k;
    for (k in x) {
      if (x.hasOwnProperty(k)) {
        return false;
      }
    }
    return true;
  };

  Juxtaposition = new GR.OneOrMore(Multiplied, function(l) {
    return pairsOf(GR.Juxtaposition, l, {
      pair: function(x, y) {
        return new VL.Juxtaposition([x, y]);
      },
      cons: Cons
    });
  });

  And = new GR.DelimitedBy(DblAmpersand, Juxtaposition, function(l) {
    return pairsOf(GR.And, l, {
      pair: function(x, y) {
        return new VL.And([x, y]);
      },
      cons: Cons
    });
  });

  InclusiveOr = new GR.DelimitedBy(Column, And, function(l) {
    return pairsOf(GR.InclusiveOr, l, {
      pair: function(x, y) {
        return new VL.InclusiveOr([x != null ? x : new VL.EmptyValue, y != null ? y : new VL.EmptyValue]);
      },
      cons: function(x, y) {
        (y != null ? y : y = new VL.InclusiveOr([])).unshift(x != null ? x : new VL.EmptyValue);
        return y;
      }
    });
  });

  ExclusiveOr = new GR.DelimitedBy(Bar, InclusiveOr, function(l) {
    return pairsOf(GR.ExclusiveOr, l, {
      pair: Id,
      cons: Id
    });
  });

  Combined = ExclusiveOr;

  Bracket.a = Combined;

  FunctionalNotation.a = Combined;

  Root = new GR.Just(Combined, function(x) {
    return new GR.AnnotationRoot(x, AddMarkings);
  });

  OptionalRoot = new GR.Optional(Root, function(x) {
    return x != null ? x : new GR.Empty(function() {
      return new VL.EmptyValue;
    });
  });

  Vds = Root;

  Atom = Bracketed;

  module.exports = Vds;

  ref = {
    Atom: Atom,
    TypeReference: TypeReference,
    OptionalRoot: OptionalRoot
  };
  for (k in ref) {
    v = ref[k];
    module.exports[k] = v;
  }

}).call(this);
