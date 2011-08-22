describe("Diaspora.Widgets.UserDropdown", function() {
  var userDropdown;
  beforeEach(function() {
    spec.loadFixture("aspects_index");
    userDropdown = Diaspora.BaseWidget.instantiate("UserDropdown", $("#user_menu"));
  });

  describe("toggleDropdown", function() {
    it("adds the class 'active'", function() {
      expect(userDropdown.menuElement).not.toHaveClass("active");
      userDropdown.toggleDropdown($.Event());
      expect(userDropdown.menuElement).toHaveClass("active");
    });
  });

  describe("hideDropdown", function() {
    it("removes the class 'active' if the user clicks anywhere that isn't the menu element", function() {
      userDropdown.toggleDropdown($.Event());
      expect(userDropdown.menuElement).toHaveClass("active");

      userDropdown.hideDropdown();
      expect(userDropdown.menuElement).not.toHaveClass("active");
    });
  });
});