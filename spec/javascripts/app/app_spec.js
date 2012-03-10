describe("app", function() {
  describe("user", function() {
    it("sets the user if given one and returns the current user", function() {
      expect(app.user()).toBeFalsy()
    });

    it("sets the user if given one and returns the current user", function() {
      expect(app.user().authenticated()).toBeFalsy()
      app.user({name: "alice"});

      expect(app.user().get("name")).toEqual("alice");
    });
    
    it("returns false if the current_user isn't set", function() {
      app._user = undefined;

      expect(app.user()).toEqual(false);
    });
  });
});
