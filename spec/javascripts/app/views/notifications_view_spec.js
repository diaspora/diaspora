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
      badge = $('ul.nav > li:eq(0) .badge');
      count = parseInt(badge.text());

      this.view.updateView(this.guid, this.type, true);
      expect(parseInt(badge.text())).toBe(count + 1);

      this.view.updateView(this.guid, this.type, false);
      expect(parseInt(badge.text())).toBe(count);
    });

    it('changes the notification type count', function() {
      badge = $('ul.nav > li[data-type=' + this.type + '] .badge');
      count = parseInt(badge.text());

      this.view.updateView(this.guid, this.type, true);
      expect(parseInt(badge.text())).toBe(count + 1);

      this.view.updateView(this.guid, this.type, false);
      expect(parseInt(badge.text())).toBe(count);
    });

    it('toggles the unread class and changes the link text', function() {
      this.view.updateView(this.readN.data('guid'), this.readN.data('type'), true);
      expect(this.readN.hasClass('unread')).toBeTruethy;
      expect(this.readN.hasClass('read')).toBeFalsy;
      expect(this.readN.find('.unread-toggle').text()).toContain(Diaspora.I18n.t('notifications.mark_read'));

      this.view.updateView(this.readN.data('guid'), this.readN.data('type'), false);
      expect(this.readN.hasClass('read')).toBeTruethy;
      expect(this.readN.hasClass('unread')).toBeFalsy;
      expect(this.readN.find('.unread-toggle').text()).toContain(Diaspora.I18n.t('notifications.mark_unread'));
    });
  });
});
