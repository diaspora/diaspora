describe("Handlebars helpers", function() {
  beforeEach(function() {
    Diaspora.I18n.load({people: {helper: {"is_not_sharing": "<%= name %> is not sharing with you"}}});
  });

  describe("sharingMessage", function() {
    it("escapes the person's name", function() {
      var person = { name: "\"><script>alert(0)</script> \"><script>alert(0)</script>"};
      expect(Handlebars.helpers.sharingMessage(person)).not.toMatch(/<script>/);
    });
  });
});
