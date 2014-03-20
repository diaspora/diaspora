/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
describe("Diaspora.Widgets.Notifications", function() {
  var changeNotificationCountSpy, notifications, incrementCountSpy, decrementCountSpy;

  beforeEach(function() {
    spec.loadFixture("aspects_index");
    this.view = new app.views.Header().render();

    notifications = Diaspora.BaseWidget.instantiate("Notifications", this.view.$("#notification_badge .badge_count"), this.view.$(".notifications"));

    changeNotificationCountSpy = spyOn(notifications, "changeNotificationCount").and.callThrough();
    incrementCountSpy = spyOn(notifications, "incrementCount").and.callThrough();
    decrementCountSpy = spyOn(notifications, "decrementCount").and.callThrough();
  });

  describe("clickSuccess", function(){
    it("changes the css to a read cell at stream element", function() {
      this.view.$(".notifications").html(
        '<div id="1" class="stream_element read" data-guid=1></div>' +
        '<div id="2" class="stream_element unread" data-guid=2></div>'
      );
      notifications.clickSuccess({guid:2,unread:false});
      expect( this.view.$('.stream_element#2')).toHaveClass("read");
    });
    it("changes the css to a read cell at notications element", function() {
      this.view.$(".notifications").html(
        '<div id="1" class="notification_element read" data-guid=1></div>' +
        '<div id="2" class="notification_element unread" data-guid=2></div>'
      );
      notifications.clickSuccess({guid:2,unread:false});
      expect( this.view.$('.notification_element#2')).toHaveClass("read");
    });
    it("changes the css to an unread cell at stream element", function() {
      this.view.$(".notifications").html(
        '<div id="1" class="stream_element read" data-guid=1></div>' +
        '<div id="2" class="stream_element unread" data-guid=2></div>'
      );
      notifications.clickSuccess({guid:1,unread:true});
      expect( this.view.$('.stream_element#1')).toHaveClass("unread");
    });
    it("changes the css to an unread cell at notications element", function() {
      this.view.$(".notifications").html(
        '<div id="1" class="notification_element read" data-guid=1></div>' +
        '<div id="2" class="notification_element unread" data-guid=2></div>'
      );
      notifications.clickSuccess({guid:1,unread:true});
      expect( this.view.$('.notification_element#1')).toHaveClass("unread");
    });


    it("calls Notifications.decrementCount on a read cell at stream/notification element", function() {
      notifications.clickSuccess(JSON.stringify({guid:1,unread:false}));
      expect(notifications.decrementCount).toHaveBeenCalled();
    });
    it("calls Notifications.incrementCount on a unread cell at stream/notification element", function() {
      notifications.clickSuccess({guid:1,unread:true});
      expect(notifications.incrementCount).toHaveBeenCalled();
    });
  });

  describe("decrementCount", function() {
    it("wont decrement Notifications.count below zero", function() {
      var originalCount = notifications.count;
      notifications.decrementCount();
      expect(originalCount).toEqual(0);
      expect(notifications.count).toEqual(0);
    });

    it("decrements Notifications.count", function() {
      notifications.incrementCount();
      notifications.incrementCount();
      var originalCount = notifications.count;
      notifications.decrementCount();
      expect(notifications.count).toBeLessThan(originalCount);
    });

    it("calls Notifications.changeNotificationCount", function() {
      notifications.decrementCount();
      expect(notifications.changeNotificationCount).toHaveBeenCalled();
    })
  });

  describe("incrementCount", function() {
    it("increments Notifications.count", function() {
      var originalCount = notifications.count;
      notifications.incrementCount();
      expect(notifications.count).toBeGreaterThan(originalCount);
    });

    it("calls Notifications.changeNotificationCount", function() {
      notifications.incrementCount();
      expect(notifications.changeNotificationCount).toHaveBeenCalled();
    });
  });

  describe("showNotification", function() {
    it("prepends a div to div#notifications", function() {
      expect(this.view.$(".notifications div").length).toEqual(1);

      notifications.showNotification({
        html: '<div class="notification_element"></div>'
      });

      expect(this.view.$(".notifications div").length).toEqual(2);
    });

    it("only increments the notification count if specified to do so", function() {
      var originalCount = notifications.count;

      notifications.showNotification({
        html: '<div class="notification"></div>',
        incrementCount: false
      });

      expect(notifications.count).toEqual(originalCount);

    });
  });
});
