/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
describe("Diaspora.Widgets.Notifications", function() {
  var changeNotificationCountSpy, notifications, incrementCountSpy, decrementCountSpy;

  beforeEach(function() {
    spec.loadFixture("aspects_index");
    notifications = Diaspora.BaseWidget.instantiate("Notifications", $("#notifications"), $("#notification_badge .badge_count"));

    changeNotificationCountSpy = spyOn(notifications, "changeNotificationCount").andCallThrough();
    incrementCountSpy = spyOn(notifications, "incrementCount").andCallThrough();
    decrementCountSpy = spyOn(notifications, "decrementCount").andCallThrough();
  });

  describe("clickSuccess", function(){
    it("changes the css to a read cell", function() {
      $(".notifications").html(
        '<div id="1" class="stream_element read" data-guid=1></div>' +
        '<div id="2" class="stream_element unread" data-guid=2></div>'
      );
      notifications.clickSuccess(JSON.stringify({guid:2,unread:false}));
      expect( $('.stream_element#2')).toHaveClass("read");
    });
    it("changes the css to an unread cell", function() {
      $(".notifications").html(
        '<div id="1" class="stream_element read" data-guid=1></div>' +
        '<div id="2" class="stream_element unread" data-guid=2></div>'
      );
      notifications.clickSuccess(JSON.stringify({guid:1,unread:true}));
      expect( $('.stream_element#1')).toHaveClass("unread");
    });


    it("calls Notifications.decrementCount on a read cell", function() {
      notifications.clickSuccess(JSON.stringify({guid:1,unread:false}));
      expect(notifications.decrementCount).toHaveBeenCalled();
    });
    it("calls Notifications.incrementCount on a unread cell", function() {
      notifications.clickSuccess(JSON.stringify({guid:1,unread:true}));
      expect(notifications.incrementCount).toHaveBeenCalled();
    });
  });

  describe("decrementCount", function() {
    it("decrements Notifications.count", function() {
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
      expect($("#notifications div").length).toEqual(0);

      notifications.showNotification({
        html: '<div class="notification"></div>'
      });

      expect($("#notifications div").length).toEqual(1);
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
