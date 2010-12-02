describe("Validation", function() { 
  describe("rules", function() {
    describe("username", function() {
      describe("characters", function() {
        it("is the regex for checking if we allow what the user typed", function() { 
          expect((typeof Validation.rules.username.characters.test === "function")).toBeTruthy();
        });
      });
    });
  });
  describe("events", function() { 
    describe("usernameKeypress", function() { 
      it("doesn't allow the user to type anything but letters, numbers and underscores", function() { 
        expect(Validation.rules.username.characters.test("*")).toBeFalsy();
        expect(Validation.rules.username.characters.test("Aa_")).toBeTruthy();
        expect(Validation.rules.username.characters.test("ffffffffffffffffffffffffffffffffff")).toBeFalsy();
      }); 
    });
  });
});
