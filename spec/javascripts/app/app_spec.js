describe("app", function() {
  describe("user", function() {
    it("sets the user if given one and returns the current user", function() {
      expect(app.user()).toBeFalsy()

      app.user({name: "alice"});

      expect(app.user()).toEqual({name: "alice"});
    });
  });
});
