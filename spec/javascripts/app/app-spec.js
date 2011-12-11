describe("App", function() {
  describe("user", function() {
    it("sets the user if given one and returns the current user", function() {
      expect(App.user()).toBeUndefined();

      App.user({name: "alice"});

      expect(App.user()).toEqual({name: "alice"});
    });
  });
});
