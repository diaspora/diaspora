describe("app.collections.Notifications", function() {
  describe("initialize", function() {
    it("calls fetch", function() {
      spyOn(app.collections.Notifications.prototype, "fetch");
      new app.collections.Notifications();
      expect(app.collections.Notifications.prototype.fetch).toHaveBeenCalled();
    });

    it("calls Diaspora.BrowserNotification.requestPermission", function() {
      spyOn(Diaspora.BrowserNotification, "requestPermission");
      new app.collections.Notifications();
      expect(Diaspora.BrowserNotification.requestPermission).toHaveBeenCalled();
    });

    it("initializes attributes", function() {
      var target = new app.collections.Notifications();
      expect(target.model).toBe(app.models.Notification);
      /* eslint-disable camelcase */
      expect(target.url).toBe(Routes.notifications({per_page: 10, page: 1}));
      /* eslint-enable camelcase */
      expect(target.page).toBe(2);
      expect(target.perPage).toBe(5);
      expect(target.unreadCount).toBe(0);
      expect(target.unreadCountByType).toEqual({});
    });

    it("repeatedly calls pollNotifications", function() {
      spyOn(app.collections.Notifications.prototype, "pollNotifications").and.callThrough();
      var collection = new app.collections.Notifications();
      expect(app.collections.Notifications.prototype.pollNotifications).not.toHaveBeenCalled();
      jasmine.clock().tick(collection.timeout);
      expect(app.collections.Notifications.prototype.pollNotifications).toHaveBeenCalledTimes(1);
      jasmine.clock().tick(collection.timeout);
      expect(app.collections.Notifications.prototype.pollNotifications).toHaveBeenCalledTimes(2);
    });
  });

  describe("pollNotifications", function() {
    beforeEach(function() {
      this.target = new app.collections.Notifications();
    });

    it("calls fetch", function() {
      spyOn(this.target, "fetch");
      this.target.pollNotifications();
      expect(this.target.fetch).toHaveBeenCalled();
    });

    it("doesn't call Diaspora.BrowserNotification.spawnNotification when there are no new notifications", function() {
      spyOn(Diaspora.BrowserNotification, "spawnNotification");
      this.target.pollNotifications();
      this.target.trigger("finishedLoading");
      expect(Diaspora.BrowserNotification.spawnNotification).not.toHaveBeenCalled();
    });

    it("calls Diaspora.BrowserNotification.spawnNotification when there are new notifications", function() {
      spyOn(Diaspora.BrowserNotification, "spawnNotification");
      spyOn(app.collections.Notifications.prototype, "fetch").and.callFake(function() {
        this.target.unreadCount++;
      }.bind(this));
      this.target.pollNotifications();
      this.target.trigger("finishedLoading");
      expect(Diaspora.BrowserNotification.spawnNotification).toHaveBeenCalled();
    });
  });

  describe("fetch", function() {
    it("calls Backbone.Collection.prototype.fetch with correct parameters", function() {
      var target = new app.collections.Notifications();
      spyOn(Backbone.Collection.prototype, "fetch");
      target.fetch({foo: "bar", remove: "bar", merge: "bar", parse: "bar"});
      expect(Backbone.Collection.prototype.fetch.calls.mostRecent().args).toEqual([{
        foo: "bar",
        remove: false,
        merge: true,
        parse: true
      }]);
    });
  });

  describe("fetchMore", function() {
    beforeEach(function() {
      this.target = new app.collections.Notifications();
      spyOn(app.collections.Notifications.prototype, "fetch");
    });

    it("fetches notifications when there are more notifications to be fetched", function() {
      this.target.length = 15;
      this.target.fetchMore();
      /* eslint-disable camelcase */
      var route = Routes.notifications({per_page: 5, page: 3});
      /* eslint-enable camelcase */
      expect(app.collections.Notifications.prototype.fetch).toHaveBeenCalledWith({url: route, pushBack: true});
      expect(this.target.page).toBe(3);
    });

    it("doesn't fetch notifications when there are no more notifications to be fetched", function() {
      this.target.length = 0;
      this.target.fetchMore();
      expect(app.collections.Notifications.prototype.fetch).not.toHaveBeenCalled();
      expect(this.target.page).toBe(2);
    });
  });

  describe("set", function() {
    beforeEach(function() {
      this.target = new app.collections.Notifications();
    });

    context("calls to Backbone.Collection.prototype.set", function() {
      beforeEach(function() {
        spyOn(Backbone.Collection.prototype, "set");
      });

      it("calls app.collections.Notifications.prototype.set", function() {
        this.target.set([]);
        expect(Backbone.Collection.prototype.set).toHaveBeenCalledWith([], {at: 0});
      });

      it("inserts the items at the beginning of the collection if option 'pushBack' is false", function() {
        this.target.length = 15;
        this.target.set([], {pushBack: false});
        expect(Backbone.Collection.prototype.set).toHaveBeenCalledWith([], {pushBack: false, at: 0});
      });

      it("inserts the items at the end of the collection if option 'pushBack' is true", function() {
        this.target.length = 15;
        this.target.set([], {pushBack: true});
        expect(Backbone.Collection.prototype.set).toHaveBeenCalledWith([], {pushBack: true, at: 15});
      });
    });

    context("events", function() {
      beforeEach(function() {
        spyOn(Backbone.Collection.prototype, "set").and.callThrough();
        spyOn(app.collections.Notifications.prototype, "trigger").and.callThrough();
        this.model1 = new app.models.Notification({"reshared": {id: 1}, "type": "reshared"});
        this.model2 = new app.models.Notification({"reshared": {id: 2}, "type": "reshared"});
        this.model3 = new app.models.Notification({"reshared": {id: 3}, "type": "reshared"});
        this.model4 = new app.models.Notification({"reshared": {id: 4}, "type": "reshared"});
      });

      it("triggers a 'pushFront' event for each model in reverse order when option 'pushBack' is false", function() {
        this.target.set([this.model1, this.model2, this.model3, this.model4], {pushBack: false});

        var calls = app.collections.Notifications.prototype.trigger.calls;

        var index = calls.count() - 5;
        expect(calls.argsFor(index)).toEqual(["pushFront", this.model4]);
        expect(calls.argsFor(index + 1)).toEqual(["pushFront", this.model3]);
        expect(calls.argsFor(index + 2)).toEqual(["pushFront", this.model2]);
        expect(calls.argsFor(index + 3)).toEqual(["pushFront", this.model1]);
      });

      it("triggers a 'pushBack' event for each model in normal order when option 'pushBack' is true", function() {
        this.target.set([this.model1, this.model2, this.model3, this.model4], {pushBack: true});

        var calls = app.collections.Notifications.prototype.trigger.calls;

        var index = calls.count() - 5;
        expect(calls.argsFor(index)).toEqual(["pushBack", this.model1]);
        expect(calls.argsFor(index + 1)).toEqual(["pushBack", this.model2]);
        expect(calls.argsFor(index + 2)).toEqual(["pushBack", this.model3]);
        expect(calls.argsFor(index + 3)).toEqual(["pushBack", this.model4]);
      });

      it("triggers a 'finishedLoading' event at the end of the process", function() {
        this.target.set([]);
        expect(app.collections.Notifications.prototype.trigger).toHaveBeenCalledWith("finishedLoading");
      });
    });
  });

  describe("parse", function() {
    beforeEach(function() {
      this.target = new app.collections.Notifications();
    });

    it("sets the unreadCount and unreadCountByType attributes", function() {
      expect(this.target.unreadCount).toBe(0);
      expect(this.target.unreadCountByType).toEqual({});

      /* eslint-disable camelcase */
      this.target.parse({
        unread_count: 15,
        unread_count_by_type: {reshared: 6},
        notification_list: []
      });
      /* eslint-enable camelcase */

      expect(this.target.unreadCount).toBe(15);
      expect(this.target.unreadCountByType).toEqual({reshared: 6});
    });

    it("correctly parses the result", function() {
      /* eslint-disable camelcase */
      var parsed = this.target.parse({
        unread_count: 15,
        unread_count_by_type: {reshared: 6},
        notification_list: [{"reshared": {id: 1}, "type": "reshared"}]
      });
      /* eslint-enable camelcase */

      expect(parsed.length).toEqual(1);
    });

    it("correctly binds the change:unread event", function() {
      spyOn(this.target, "trigger");

      /* eslint-disable camelcase */
      var parsed = this.target.parse({
        unread_count: 15,
        unread_count_by_type: {reshared: 6},
        notification_list: [{"reshared": {id: 1}, "type": "reshared"}]
      });
      /* eslint-enable camelcase */

      parsed[0].set("unread", true);
      expect(this.target.trigger).toHaveBeenCalledWith("update");
    });

    it("correctly binds the userChangedUnreadStatus event", function() {
      spyOn(this.target, "onChangedUnreadStatus");

      /* eslint-disable camelcase */
      var parsed = this.target.parse({
        unread_count: 15,
        unread_count_by_type: {reshared: 6},
        notification_list: [{"reshared": {id: 1}, "type": "reshared"}]
      });
      /* eslint-enable camelcase */

      parsed[0].set("unread", true);
      parsed[0].trigger("userChangedUnreadStatus", parsed[0]);

      expect(this.target.onChangedUnreadStatus).toHaveBeenCalled();
    });
  });

  describe("onChangedUnreadStatus", function() {
    it("increases the unread counts when model's unread attribute is true", function() {
      var target = new app.collections.Notifications();
      var model = new app.models.Notification({"reshared": {id: 1, unread: true}, "type": "reshared"});

      target.unreadCount = 15;
      target.unreadCountByType.reshared = 6;

      target.onChangedUnreadStatus(model);

      expect(target.unreadCount).toBe(16);
      expect(target.unreadCountByType.reshared).toBe(7);
    });

    it("decreases the unread counts when model's unread attribute is false", function() {
      var target = new app.collections.Notifications();
      var model = new app.models.Notification({"reshared": {id: 1, unread: false}, "type": "reshared"});

      target.unreadCount = 15;
      target.unreadCountByType.reshared = 6;

      target.onChangedUnreadStatus(model);

      expect(target.unreadCount).toBe(14);
      expect(target.unreadCountByType.reshared).toBe(5);
    });
  });
});
