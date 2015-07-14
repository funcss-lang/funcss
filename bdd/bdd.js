mocha.setup("bdd");
$frame = $("#frame");
frame = $frame[0];
function test(url, spec, f) {
  specify(spec, function(done) {
    // go to url and call f() after loading
    frame.src = url;
    var mocha = this;
    $frame.one("load", function() {
      setTimeout(function() {
        f.call(mocha, frame.contentDocument, done);
        // only call done() if f() does not wish to call it (like in Mocha)
        if (f.length <= 1) { done(); } 
      });
    });
  });
}
