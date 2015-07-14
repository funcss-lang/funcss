describe("simple stylesheets", function() {
  test("./stylesheet/simple_stylesheet.html", "can set yellow background", function(doc) {
    $("body", doc).css("background-color").should.equal("rgb(255, 255, 0)");
  });
});
