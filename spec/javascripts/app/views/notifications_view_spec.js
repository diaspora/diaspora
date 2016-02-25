describe("app.views.Notifications", function(){
  context("on the notifications page", function() {
    beforeEach(function() {
      spec.loadFixture("notifications");
      this.view = new app.views.Notifications({el: "#notifications_container"});
    });

    describe("mark read", function() {
      beforeEach(function() {
        this.unreadN = $(".stream_element.unread").first();
        this.guid = this.unreadN.data("guid");
      });

      it("calls 'setRead'", function() {
        spyOn(this.view, "setRead");
        this.unreadN.find(".unread-toggle").trigger("click");

        expect(this.view.setRead).toHaveBeenCalledWith(this.guid);
      });
    });

    describe("mark unread", function() {
      beforeEach(function() {
        this.readN = $(".stream_element.read").first();
        this.guid = this.readN.data("guid");
      });

      it("calls 'setUnread'", function() {
        spyOn(this.view, "setUnread");
        this.readN.find(".unread-toggle").trigger("click");

        expect(this.view.setUnread).toHaveBeenCalledWith(this.guid);
      });
    });

    describe("updateView", function() {
      beforeEach(function() {
        this.readN = $(".stream_element.read").first();
        this.guid = this.readN.data("guid");
        this.type = this.readN.data("type");
      });

      it("changes the 'all notifications' count", function() {
        var badge = $(".list-group > a:eq(0) .badge");
        var count = parseInt(badge.text());

        this.view.updateView(this.guid, this.type, true);
        expect(parseInt(badge.text())).toBe(count + 1);

        this.view.updateView(this.guid, this.type, false);
        expect(parseInt(badge.text())).toBe(count);
      });

      it("changes the notification type count", function() {
        var badge = $(".list-group > a[data-type=" + this.type + "] .badge");
        var count = parseInt(badge.text());

        this.view.updateView(this.guid, this.type, true);
        expect(parseInt(badge.text())).toBe(count + 1);

        this.view.updateView(this.guid, this.type, false);
        expect(parseInt(badge.text())).toBe(count);
      });

      it("toggles the unread class and changes the title", function() {
        this.view.updateView(this.readN.data("guid"), this.readN.data("type"), true);
        expect(this.readN.hasClass("unread")).toBeTruthy();
        expect(this.readN.hasClass("read")).toBeFalsy();
        expect(this.readN.find(".unread-toggle .entypo-eye").data("original-title")).toBe(
          Diaspora.I18n.t("notifications.mark_read")
        );

        this.view.updateView(this.readN.data("guid"), this.readN.data("type"), false);
        expect(this.readN.hasClass("read")).toBeTruthy();
        expect(this.readN.hasClass("unread")).toBeFalsy();
        expect(this.readN.find(".unread-toggle .entypo-eye").data("original-title")).toBe(
          Diaspora.I18n.t("notifications.mark_unread")
        );
      });

      context("with a header", function() {
        beforeEach(function() {
          /* jshint camelcase: false */
          loginAs({name: "alice", avatar: {small: "http://avatar.com/photo.jpg"}, notifications_count: 2, guid: "foo"});
          /* jshint camelcase: true */
          gon.appConfig = {settings: {podname: "MyPod"}};
          this.header = new app.views.Header();
          $("header").prepend(this.header.el);
          this.header.render();
        });

        it("changes the header notifications count", function() {
          var badge1 = $(".notifications-link:eq(0) .badge");
          var badge2 = $(".notifications-link:eq(1) .badge");
          var count = parseInt(badge1.text(), 10);

          this.view.updateView(this.guid, this.type, true);
          expect(parseInt(badge1.text(), 10)).toBe(count + 1);

          this.view.updateView(this.guid, this.type, false);
          expect(parseInt(badge1.text(), 10)).toBe(count);

          this.view.updateView(this.guid, this.type, true);
          expect(parseInt(badge2.text(), 10)).toBe(count + 1);

          this.view.updateView(this.guid, this.type, false);
          expect(parseInt(badge2.text(), 10)).toBe(count);
        });
      });
    });

    describe("markAllRead", function() {
      it("calls setRead for each unread notification", function(){
        spyOn(this.view, "setRead");
        this.view.markAllRead();
        expect(this.view.setRead).toHaveBeenCalledWith(this.view.$(".stream_element.unread").eq(0).data("guid"));
        this.view.markAllRead();
        expect(this.view.setRead).toHaveBeenCalledWith(this.view.$(".stream_element.unread").eq(1).data("guid"));
      });
    });
  });

  context("on the contacts page", function() {
    beforeEach(function() {
      spec.loadFixture("aspects_manage");
      this.view = new app.views.Notifications({el: "#notifications_container"});
      /* jshint camelcase: false */
      loginAs({name: "alice", avatar: {small: "http://avatar.com/photo.jpg"}, notifications_count: 2, guid: "foo"});
      /* jshint camelcase: true */
      gon.appConfig = {settings: {podname: "MyPod"}};
      this.header = new app.views.Header();
      $("header").prepend(this.header.el);
      this.header.render();
    });

    describe("updateView", function() {
      it("changes the header notifications count", function() {
        var badge1 = $(".notifications-link:eq(0) .badge");
        var badge2 = $(".notifications-link:eq(1) .badge");
        var count = parseInt(badge1.text(), 10);

        this.view.updateView(this.guid, this.type, true);
        expect(parseInt(badge1.text(), 10)).toBe(count + 1);

        this.view.updateView(this.guid, this.type, false);
        expect(parseInt(badge1.text(), 10)).toBe(count);

        this.view.updateView(this.guid, this.type, true);
        expect(parseInt(badge2.text(), 10)).toBe(count + 1);

        this.view.updateView(this.guid, this.type, false);
        expect(parseInt(badge2.text(), 10)).toBe(count);
      });

      it("doesn't change the contacts count", function() {
        expect($("#aspect_nav .badge").length).toBeGreaterThan(0);
        $("#aspect_nav .badge").each(function(index, el) {
          $(el).text(index + 1337);
        });

        this.view.updateView(this.guid, this.type, true);
        $("#aspect_nav .badge").each(function(index, el) {
          expect(parseInt($(el).text(), 10)).toBe(index + 1337);
        });

        this.view.updateView(this.guid, this.type, false);
        $("#aspect_nav .badge").each(function(index, el) {
          expect(parseInt($(el).text(), 10)).toBe(index + 1337);
        });
      });
    });
  });
});
