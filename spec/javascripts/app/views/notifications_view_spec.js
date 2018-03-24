describe("app.views.Notifications", function() {
  beforeEach(function() {
    this.collection = new app.collections.Notifications();
    this.collection.fetch();
    jasmine.Ajax.requests.mostRecent().respondWith({
      status: 200,
      responseText: spec.readFixture("notifications_collection")
    });
  });

  context("on the notifications page", function() {
    beforeEach(function() {
      spec.loadFixture("notifications");
      this.view = new app.views.Notifications({el: "#notifications_container", collection: this.collection});
    });

    describe("bindCollectionEvents", function() {
      beforeEach(function() {
        this.view.collection.off("change");
        this.view.collection.off("update");
        spyOn(this.view, "onChangedUnreadStatus");
        spyOn(this.view, "updateView");
      });

      it("binds collection events", function() {
        this.view.bindCollectionEvents();

        this.collection.trigger("change");
        this.collection.trigger("update");

        expect(this.view.onChangedUnreadStatus).toHaveBeenCalled();
        expect(this.view.updateView).toHaveBeenCalled();
      });
    });

    describe("mark read", function() {
      beforeEach(function() {
        this.unreadN = $(".stream-element.unread").first();
        this.guid = this.unreadN.data("guid");
      });

      it("calls collection's 'setRead'", function() {
        spyOn(this.collection, "setRead");
        this.unreadN.find(".unread-toggle").trigger("click");

        expect(this.collection.setRead).toHaveBeenCalledWith(this.guid);
      });
    });

    describe("mark unread", function() {
      beforeEach(function() {
        this.readN = $(".stream-element.read").first();
        this.guid = this.readN.data("guid");
      });

      it("calls collection's 'setUnread'", function() {
        spyOn(this.collection, "setUnread");
        this.readN.find(".unread-toggle").trigger("click");

        expect(this.collection.setUnread).toHaveBeenCalledWith(this.guid);
      });
    });

    describe("updateView", function() {
      beforeEach(function() {
        this.readN = $(".stream-element.read").first();
        this.guid = this.readN.data("guid");
        this.type = this.readN.data("type");
      });

      it("increases the 'all notifications' count", function() {
        var badge = $(".list-group > a:eq(0) .badge");
        expect(parseInt(badge.text(), 10)).toBe(2);

        this.collection.unreadCount++;
        this.view.updateView();
        expect(parseInt(badge.text(), 10)).toBe(3);

        this.view.updateView();
        expect(parseInt(badge.text(), 10)).toBe(3);
      });

      it("decreases the 'all notifications' count", function() {
        var badge = $(".list-group > a:eq(0) .badge");
        expect(parseInt(badge.text(), 10)).toBe(2);

        this.collection.unreadCount--;
        this.view.updateView();
        expect(parseInt(badge.text(), 10)).toBe(1);

        this.view.updateView();
        expect(parseInt(badge.text(), 10)).toBe(1);
      });

      it("increases the notification type count", function() {
        var badge = $(".list-group > a[data-type=" + this.type + "] .badge");

        expect(parseInt(badge.text(), 10)).toBe(1);

        this.collection.unreadCountByType[this.type]++;
        this.view.updateView();
        expect(parseInt(badge.text(), 10)).toBe(2);

        this.view.updateView();
        expect(parseInt(badge.text(), 10)).toBe(2);
      });

      it("decreases the notification type count", function() {
        var badge = $(".list-group > a[data-type=" + this.type + "] .badge");

        expect(parseInt(badge.text(), 10)).toBe(1);

        this.collection.unreadCountByType[this.type]--;
        this.view.updateView();
        expect(parseInt(badge.text(), 10)).toBe(0);

        this.view.updateView();
        expect(parseInt(badge.text(), 10)).toBe(0);
      });

      it("hides badge count when notification count is zero", function() {
        Object.keys(this.collection.unreadCountByType).forEach(function(notificationType) {
          this.collection.unreadCountByType[notificationType] = 0;
        }.bind(this));
        this.collection.unreadCount = 0;

        this.view.updateView();

        expect($("a .badge")).toHaveClass("hidden");
      });

      context("with a header", function() {
        beforeEach(function() {
          /* jshint camelcase: false */
          loginAs({name: "alice", avatar: {small: "http://avatar.com/photo.jpg"}, notifications_count: 2, guid: "foo"});
          /* jshint camelcase: true */
          gon.appConfig = {settings: {podname: "MyPod"}};
          app.notificationsCollection = this.collection;
          this.header = new app.views.Header();
          $("header").prepend(this.header.el);
          this.header.render();
        });

        it("changes the header notifications count", function() {
          var badge = $(".notifications-link .badge");

          expect(parseInt(badge.text(), 10)).toBe(this.collection.unreadCount);

          this.collection.unreadCount++;
          this.view.updateView();
          expect(parseInt(badge.text(), 10)).toBe(this.collection.unreadCount);
        });

        it("disables the mark-all-read-link button", function() {
          expect($("a#mark-all-read-link")).not.toHaveClass("disabled");
          this.collection.unreadCount = 0;
          this.view.updateView();
          expect($("a#mark-all-read-link")).toHaveClass("disabled");
        });
      });
    });

    describe("markAllRead", function() {
      it("calls collection#setAllRead", function() {
        spyOn(this.collection, "setAllRead");
        this.view.markAllRead($.Event());
        expect(this.collection.setAllRead).toHaveBeenCalled();
      });

      it("calls preventDefault", function() {
        var evt = $.Event();
        spyOn(evt, "preventDefault");
        this.view.markAllRead(evt);
        expect(evt.preventDefault).toHaveBeenCalled();
      });
    });

    describe("onChangedUnreadStatus", function() {
      beforeEach(function() {
        this.modelRead = new app.models.Notification({});
        this.modelRead.set("unread", false);
        this.modelRead.guid = $(".stream-element.unread").first().data("guid");
        this.modelUnread = new app.models.Notification({});
        this.modelUnread.set("unread", true);
        this.modelUnread.guid = $(".stream-element.read").first().data("guid");
      });

      it("Adds the unread class and changes the title", function() {
        var unreadEl = $(".stream-element[data-guid=" + this.modelUnread.guid + "]");

        expect(unreadEl.hasClass("read")).toBeTruthy();
        expect(unreadEl.hasClass("unread")).toBeFalsy();
        expect(unreadEl.find(".unread-toggle .entypo-eye").attr("data-original-title")).toBe(
          Diaspora.I18n.t("notifications.mark_unread")
        );

        this.view.onChangedUnreadStatus(this.modelUnread);
        expect(unreadEl.hasClass("unread")).toBeTruthy();
        expect(unreadEl.hasClass("read")).toBeFalsy();
        expect(unreadEl.find(".unread-toggle .entypo-eye").attr("data-original-title")).toBe(
          Diaspora.I18n.t("notifications.mark_read")
        );
      });

      it("Removes the unread class and changes the title", function() {
        var readEl = $(".stream-element[data-guid=" + this.modelRead.guid + "]");

        expect(readEl.hasClass("unread")).toBeTruthy();
        expect(readEl.hasClass("read")).toBeFalsy();
        expect(readEl.find(".unread-toggle .entypo-eye").attr("data-original-title")).toBe(
          Diaspora.I18n.t("notifications.mark_read")
        );

        this.view.onChangedUnreadStatus(this.modelRead);
        expect(readEl.hasClass("read")).toBeTruthy();
        expect(readEl.hasClass("unread")).toBeFalsy();
        expect(readEl.find(".unread-toggle .entypo-eye").attr("data-original-title")).toBe(
          Diaspora.I18n.t("notifications.mark_unread")
        );
      });
    });
  });

  context("on the contacts page", function() {
    beforeEach(function() {
      spec.loadFixture("aspects_manage");
      this.view = new app.views.Notifications({el: "#notifications_container", collection: this.collection});
      /* jshint camelcase: false */
      loginAs({name: "alice", avatar: {small: "http://avatar.com/photo.jpg"}, notifications_count: 2, guid: "foo"});
      /* jshint camelcase: true */
      gon.appConfig = {settings: {podname: "MyPod"}};
      app.notificationsCollection = this.collection;
      this.header = new app.views.Header();
      $("header").prepend(this.header.el);
      this.header.render();
    });

    describe("updateView", function() {
      it("doesn't change the contacts count", function() {
        expect($("#aspect_nav .badge").length).toBeGreaterThan(0);
        $("#aspect_nav .badge").each(function(index, el) {
          $(el).text(index + 1337);
        });

        this.view.updateView();
        $("#aspect_nav .badge").each(function(index, el) {
          expect(parseInt($(el).text(), 10)).toBe(index + 1337);
        });

        this.collection.unreadCount++;

        this.view.updateView();
        $("#aspect_nav .badge").each(function(index, el) {
          expect(parseInt($(el).text(), 10)).toBe(index + 1337);
        });
      });
    });
  });
});
