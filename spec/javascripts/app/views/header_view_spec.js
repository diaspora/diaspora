describe("App.Views.Header", function() {
  beforeEach(function() {
    // should be jasmine helper
    window.current_user = App.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    spec.loadFixture("aspects_index");
    this.view = new App.Views.Header().render();
  });

  describe("#toggleDropdown", function() {
    it("adds the class 'active'", function() {
      expect(this.view.$(".dropdown")).not.toHaveClass("active");
      this.view.toggleDropdown($.Event());
      expect(this.view.$(".dropdown")).toHaveClass("active");
    });
  });

  describe("#hideDropdown", function() {
    it("removes the class 'active' if the user clicks anywhere that isn't the menu element", function() {
      this.view.toggleDropdown($.Event());
      expect(this.view.$(".dropdown")).toHaveClass("active");

      this.view.hideDropdown($.Event());
      expect(this.view.$(".dropdown")).not.toHaveClass("active");
    });
  });
});
