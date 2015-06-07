describe("app.views.Header", function() {
  beforeEach(function() {
    this.userAttrs = {name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}};

    loginAs(this.userAttrs);

    spec.loadFixture("aspects_index");
    gon.appConfig = {settings: {podname: "MyPod"}};
    this.view = new app.views.Header().render();
  });

  describe("render", function(){
    context("notifications badge", function(){
      it("displays a count when the current user has a notification", function(){
        loginAs(_.extend(this.userAttrs, {notifications_count : 1}));
        this.view.render();
        expect(this.view.$("#notifications-link .badge").hasClass("hidden")).toBe(false);
        expect(this.view.$("#notifications-link .badge").text()).toContain("1");
      });

      it("does not display a count when the current user has a notification", function(){
        loginAs(_.extend(this.userAttrs, {notifications_count : 0}));
        this.view.render();
        expect(this.view.$("#notifications-link .badge").hasClass("hidden")).toBe(true);
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
        expect(this.view.$("#user_menu").html()).toContain("/admins");
      });

      it("does not display if the current user is not an admin", function(){
        loginAs(_.extend(this.userAttrs, {admin : false}));
        this.view.render();
        expect(this.view.$("#user_menu").html()).not.toContain("/admins");
      });
    });
  });

  describe("search", function() {
    var input;

    beforeEach(function() {
      $("#jasmine_content").html(this.view.el);
      input = $(this.view.el).find("#q");
    });

    describe("focus", function() {
      beforeEach(function(done){
        input.trigger("focusin");
        done();
      });

      it("adds the class 'active' when the user focuses the text field", function() {
        expect(input).toHaveClass("active");
      });
    });

    describe("blur", function() {
      beforeEach(function(done) {
        input.trigger("focusin").trigger("focusout");
        done();
      });

      it("removes the class 'active' when the user blurs the text field", function() {
        expect(input).not.toHaveClass("active");
      });
    });
  });
});
