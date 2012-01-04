describe("app.views.Header", function() {
  beforeEach(function() {
    // should be jasmine helper
    window.current_user = app.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    spec.loadFixture("aspects_index");
    this.view = new app.views.Header().render();
  });

  describe("render", function(){
    context("notifications badge", function(){
      it("displays a count when the current user has a notification", function(){
        window.current_user = _.extend(window.current_user, {notifications_count : 1})
        this.view.render();
        expect(this.view.$("#notification_badge .badge_count").hasClass('hidden')).toBe(false);
        expect(this.view.$("#notification_badge .badge_count").text()).toContain("1");
      })

      it("does not display a count when the current user has a notification", function(){
        window.current_user = _.extend(window.current_user, {notifications_count : 0})
        this.view.render();
        expect(this.view.$("#notification_badge .badge_count").hasClass('hidden')).toBe(true);
      })
    })

    context("messages badge", function(){
      it("displays a count when the current user has a notification", function(){
        window.current_user = _.extend(window.current_user, {unread_messages_count : 1})
        this.view.render();
        expect(this.view.$("#message_inbox_badge .badge_count").hasClass('hidden')).toBe(false);
        expect(this.view.$("#message_inbox_badge .badge_count").text()).toContain("1");
      })

      it("does not display a count when the current user has a notification", function(){
        window.current_user = _.extend(window.current_user, {unread_messages_count : 0})
        this.view.render();
        expect(this.view.$("#message_inbox_badge .badge_count").hasClass('hidden')).toBe(true);
      })
    })
  })

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
