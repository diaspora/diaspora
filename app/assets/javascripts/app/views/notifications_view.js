app.views.Notifications = Backbone.View.extend({

  events: {
    "click .unread-toggle" : "toggleUnread"
  },

  initialize: function() {
    Diaspora.page.header.notifications.setUpNotificationPage(this);
    $('.aspect_membership_dropdown').each(function(){
      new app.views.AspectMembership({el: this});
    });
  },

  toggleUnread: function(evt) {
    note = $(evt.target).closest(".stream_element");
    unread = note.hasClass("unread");

    if (unread) {
      this.setRead(note.data("guid"));
    }
    else {
      this.setUnread(note.data("guid"));
    }
  },

  setRead: function(guid) {
    $.ajax({
      url: "/notifications/" + guid,
      data: { set_unread: false },
      type: "PUT",
      context: this,
      success: this.clickSuccess
    });
  },

  setUnread: function(guid) {
    $.ajax({
      url: "/notifications/" + guid,
      data: { set_unread: true },
      type: "PUT",
      context: this,
      success: this.clickSuccess
    });
  },

  clickSuccess: function(data) {
    type = $('.stream_element[data-guid=' + data["guid"] + ']').data('type');
    this.updateView(data["guid"], type, data["unread"]);
  },

  updateView: function(guid, type, unread) {
    change = unread ? 1 : -1;
    all_notes = $('ul.nav > li:eq(0) .badge');
    type_notes = $('ul.nav > li[data-type=' + type + '] .badge');
    header_badge = $('#notification_badge .badge_count');

    note = $('.stream_element[data-guid=' + guid + ']');
    if(unread) {
      note.removeClass("read").addClass("unread");
      $(".unread-toggle", note).text(Diaspora.I18n.t('notifications.mark_read'));
    }
    else {
      note.removeClass("unread").addClass("read");
      $(".unread-toggle", note).text(Diaspora.I18n.t('notifications.mark_unread'));
    }

    all_notes.text( function(i,text) { return parseInt(text) + change });
    type_notes.text( function(i,text) { return parseInt(text) + change });
    header_badge.text( function(i,text) { return parseInt(text) + change });
    if(all_notes.text()>0){
      all_notes.addClass('badge-important').removeClass('badge-default');
    } else {
      all_notes.removeClass('badge-important').addClass('badge-default');
    }
    if(type_notes.text()>0){
      type_notes.addClass('badge-important').removeClass('badge-default');
    } else {
      type_notes.removeClass('badge-important').addClass('badge-default');
    }
    if(header_badge.text()>0){
      header_badge.removeClass('hidden');
    } else {
      header_badge.addClass('hidden');
    }
  }
});
