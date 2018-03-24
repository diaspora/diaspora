describe("Handlebars helpers", function() {
  describe("sharingMessage", function() {
    it("escapes the person's name", function() {
      var person = { name: "\"><script>alert(0)</script> \"><script>alert(0)</script>"};
      expect(Handlebars.helpers.sharingMessage(person)).not.toMatch(/<script>/);
    });
  });
});
