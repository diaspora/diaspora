describe("app.views.Header", function() {
  beforeEach(function() {
    this.userAttrs = {name: "alice", avatar: {small: "http://avatar.com/photo.jpg"}, guid: "foo" };

    loginAs(this.userAttrs);

    spec.loadFixture("aspects_index");
    app.notificationsCollection = new app.collections.Notifications();
    this.view = new app.views.Header().render();
  });

  describe("render", function(){
    context("notifications badge", function(){
      it("displays a count when the current user has a notification", function(){
        loginAs(_.extend(this.userAttrs, {notifications_count : 1}));
        this.view.render();
        expect(this.view.$(".notifications-link .badge").hasClass("hidden")).toBe(false);
        expect(this.view.$(".notifications-link .badge").text()).toContain("1");
      });

      it("does not display a count when the current user has a notification", function(){
        loginAs(_.extend(this.userAttrs, {notifications_count : 0}));
        this.view.render();
        expect(this.view.$(".notifications-link .badge").hasClass("hidden")).toBe(true);
      });
    });

    context("conversations badge", function(){
      it("displays a count when the current user has a notification", function(){
        loginAs(_.extend(this.userAttrs, {unread_messages_count : 1}));
        this.view.render();
        expect(this.view.$("#conversations-link .badge").hasClass("hidden")).toBe(false);
        expect(this.view.$("#conversations-link .badge").text()).toContain("1");
      });

      it("does not display a count when the current user has a notification", function(){
        loginAs(_.extend(this.userAttrs, {unread_messages_count : 0}));
        this.view.render();
        expect(this.view.$("#conversations-link .badge").hasClass("hidden")).toBe(true);
      });
    });

    context("admin link", function(){
      it("displays if the current user is an admin", function(){
        loginAs(_.extend(this.userAttrs, {admin : true}));
        this.view.render();
        expect(this.view.$("#user-menu").html()).toContain("/admins");
      });

      it("does not display if the current user is not an admin", function(){
        loginAs(_.extend(this.userAttrs, {admin : false}));
        this.view.render();
        expect(this.view.$("#user-menu").html()).not.toContain("/admins");
      });
    });
  });
});
