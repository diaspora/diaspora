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
      beforeEach(function() { 
        $("#jasmine_content").html(
         ' <input id="user_username" name="user[username]" size="30" type="text">'
        );
      });

      it("doesn't allow the user to type anything but letters, numbers and underscores", function() { 
        expect(Validation.rules.username.characters.test("*")).toBeFalsy();
        expect(Validation.rules.username.characters.test("Aa_")).toBeTruthy();
        expect(Validation.rules.username.characters.test("ffffffffffffffffffffffffffffffffff")).toBeFalsy();
      });
      
      it("is called when the user presses a key on #user_username") {
        spyOn(Validation.events, "usernameKeypress");
        $("#user_username").keypress();
        expect(Validation.events.usernameKeypress).toHaveBeenCalled();
      });
    });
  });
});
