describe("Validation", function() { 
  describe("rules", function() { 
    it("contains all the rules for validation");

    describe("username", function() {
      describe("characters", function() {
        it("is the regex for checking if we allow what the user typed");
      });
    });
  });
  describe("events", function() { 
    it("contains all the events that use validation methods");
    describe("usernameKeypress", function() { 

      it("doesn't allow the user to type anything but letters, numbers and underscores", function() { 
        expect(Validation.rules.username.characters.test("*")).toBeFalsy();
        expect(Validation.rules.username.characters.test("Aa_")).toBeTruthy();
        expect(Validation.rules.username.characters.test("ffffffffffffffffffffffffffffffffff")).toBeFalsy();
      }); 
    });
  });
});
