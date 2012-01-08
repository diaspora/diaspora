describe("app", function() {
  describe("user", function() {
    it("sets the user if given one and returns the current user", function() {
      expect(app.user()).toEqual({current_user : false});

      app.user({name: "alice"});

      expect(app.user()).toEqual({name: "alice"});
    });
  });
});
