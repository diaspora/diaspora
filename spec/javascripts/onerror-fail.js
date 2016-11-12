window.onerror = function(errorMsg, url, lineNumber) {
  describe("Test suite", function() {
    it("shouldn't skip tests because of syntax errors", function() {
      fail(errorMsg + " in file " + url + " in line " + lineNumber);
    });
  });
};
