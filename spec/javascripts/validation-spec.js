describe("Validation", function() { 
  describe("rules", function() {
    describe("username", function() {
      describe("characters", function() {
        it("is the regex for checking if we allow what the user typed", function() { 
          expect((typeof Validation.rules.username.characters.test === "function")).toBeTruthy();
        });
      });
    });
    describe("email", function() {
      describe("characters", function() {
         it("is the regex for checking if the input is a valid list of e-mail addresses", function() {
           expect((typeof Validation.rules.email.characters.test === "function")).toBeTruthy();
         });
      });
    });  
  });
  describe("whiteListed", function() {
     it("returns true if the keyCode is whitelisted", function() {
        expect(Validation.whiteListed(0)).toBeTruthy();
     });

     it("returns false if it's not", function() {
       expect(Validation.whiteListed(9001)).toBeFalsy();
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
    describe("emailKeypress", function() {
      it("colors the border red if the input seems to be a invalid list", function() {
        expect(Validation.rules.email.characters.test("user@example.com")).toBeTruthy();
        expect(Validation.rules.email.characters.test("user@example.com, user@example.com")).toBeTruthy();
        expect(Validation.rules.email.characters.test("user@example.com, user@example.com, user@example.com")).toBeTruthy();
        expect(Validation.rules.email.characters.test("user@example.com user@example.com")).toBeFalsy();
        expect(Validation.rules.email.characters.test("user@examplecom")).toBeFalsy();
        expect(Validation.rules.email.characters.test("userexample.com")).toBeFalsy();
        expect(Validation.rules.email.characters.test("userexamplecom")).toBeFalsy();
      });
    });
  });
});
