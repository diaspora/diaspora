/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/
describe("Diaspora", function() {
  describe("widgets", function() {
    describe("notifications", function() {
      var changeNotificationCountSpy;

      beforeEach(function() {
         changeNotificationCountSpy = spyOn(Diaspora.widgets.notifications, "changeNotificationCount").andCallThrough();
        $("#jasmine_content").html("<div id='notifications'></div>");
        Diaspora.widgets.notifications.start();
        changeNotificationCountSpy.reset();
      });

      describe("decrementCount", function() {
        it("decrements Notifications.count", function() {
          var originalCount = Diaspora.widgets.notifications.count;
          Diaspora.widgets.notifications.decrementCount();
          expect(Diaspora.widgets.notifications.count).toBeLessThan(originalCount);
        });

        it("calls Notifications.changeNotificationCount", function() {
          Diaspora.widgets.notifications.decrementCount();
          expect(Diaspora.widgets.notifications.changeNotificationCount).toHaveBeenCalled();
        })
      });

      describe("incrementCount", function() {
        it("increments Notifications.count", function() {
          var originalCount = Diaspora.widgets.notifications.count;
          Diaspora.widgets.notifications.incrementCount();
          expect(Diaspora.widgets.notifications.count).toBeGreaterThan(originalCount);
        });

        it("calls Notifications.changeNotificationCount", function() {
          Diaspora.widgets.notifications.incrementCount();
          expect(Diaspora.widgets.notifications.changeNotificationCount).toHaveBeenCalled();
        });
      });

      describe("showNotification", function() {
        it("prepends a div to div#notifications", function() {
          expect($("#notifications div").length).toEqual(0);

          Diaspora.widgets.notifications.showNotification({
            html: '<div class="notification"></div>'
          });

          expect($("#notifications div").length).toEqual(1);
        });
      });
    });
  });
});