describe("app.views.Notifications", function(){
  beforeEach(function() {
    spec.loadFixture("notifications");
    this.view = new app.views.Notifications({el: '#notifications_container'});
  });

  context('mark read', function() {
    beforeEach(function() {
      this.unreadN = $('.stream_element.unread').first();
      this.guid = this.unreadN.data("guid");
    });

    it('calls "setRead"', function() {
      spyOn(this.view, "setRead");
      this.unreadN.find('.unread-toggle').trigger('click');

      expect(this.view.setRead).toHaveBeenCalledWith(this.guid);
    });
  });

  context('mark unread', function() {
    beforeEach(function() {
      this.readN = $('.stream_element.read').first();
      this.guid = this.readN.data("guid");
    });

    it('calls "setUnread"', function() {
      spyOn(this.view, "setUnread");
      this.readN.find('.unread-toggle').trigger('click');

      expect(this.view.setUnread).toHaveBeenCalledWith(this.guid);
    });
  });

  context('updateView', function() {
    beforeEach(function() {
      this.readN = $('.stream_element.read').first();
      this.guid = this.readN.data('guid');
      this.type = this.readN.data('type');
    });

    it('changes the "all notifications" count', function() {
      var badge = $('ul.nav > li:eq(0) .badge');
      var count = parseInt(badge.text());

      this.view.updateView(this.guid, this.type, true);
      expect(parseInt(badge.text())).toBe(count + 1);

      this.view.updateView(this.guid, this.type, false);
      expect(parseInt(badge.text())).toBe(count);
    });

    it('changes the notification type count', function() {
      var badge = $('ul.nav > li[data-type=' + this.type + '] .badge');
      var count = parseInt(badge.text());

      this.view.updateView(this.guid, this.type, true);
      expect(parseInt(badge.text())).toBe(count + 1);

      this.view.updateView(this.guid, this.type, false);
      expect(parseInt(badge.text())).toBe(count);
    });

    it('toggles the unread class and changes the title', function() {
      this.view.updateView(this.readN.data('guid'), this.readN.data('type'), true);
      expect(this.readN.hasClass('unread')).toBeTruthy();
      expect(this.readN.hasClass('read')).toBeFalsy();
      expect(this.readN.find('.unread-toggle .entypo').data('original-title')).toBe(Diaspora.I18n.t('notifications.mark_read'));

      this.view.updateView(this.readN.data('guid'), this.readN.data('type'), false);
      expect(this.readN.hasClass('read')).toBeTruthy();
      expect(this.readN.hasClass('unread')).toBeFalsy();
      expect(this.readN.find('.unread-toggle .entypo').data('original-title')).toBe(Diaspora.I18n.t('notifications.mark_unread'));
    });

    context("with a header", function() {
      beforeEach(function() {
        loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}, notifications_count : 2});
        this.header = new app.views.Header();
        $("header").prepend(this.header.el);
        this.header.render();
      });

      it("changes the header notifications count", function() {
        var badge = $("#notification_badge .badge_count");
        var count = parseInt(badge.text(), 10);

        this.view.updateView(this.guid, this.type, true);
        expect(parseInt(badge.text(), 10)).toBe(count + 1);

        this.view.updateView(this.guid, this.type, false);
        expect(parseInt(badge.text(), 10)).toBe(count);
      });

      context("markAllRead", function() {
        it("calls setRead for each unread notification", function(){
          spyOn(this.view, "setRead");
          this.view.markAllRead();
          expect(this.view.setRead).toHaveBeenCalledWith(this.view.$('.stream_element.unread').eq(0).data('guid'));
          this.view.markAllRead();
          expect(this.view.setRead).toHaveBeenCalledWith(this.view.$('.stream_element.unread').eq(1).data('guid'));
          });
        });
    });
  });
});
