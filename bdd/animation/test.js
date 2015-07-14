describe("t()", function() {
  test("./animation/t.html", "moves with 1px/s", function(doc, done) {
    this.timeout(5000);
    this.slow(5000);
    var a = $("span", doc)[0].getBoundingClientRect().left;
    setTimeout(function() {
      var b = $("span", doc)[0].getBoundingClientRect().left;
      if (1 <= b-a && b-a <= 2) {
        done();
      } else {
        if (a == b) {
          done(new Error("does not move"));
        } else if (1 > b-a) {
          done(new Error("moves too slow"));
        } else if (2 < b-a) {
          done(new Error("moves too fast"));
        }
      }
    }, 1500);
  });
});
