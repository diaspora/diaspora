// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Notifications = Backbone.View.extend({

  events: {
    "click .unread-toggle" : "toggleUnread",
    "click #mark_all_read_link": "markAllRead"
  },

  initialize: function() {
    $(".unread-toggle .entypo").tooltip();
    app.helpers.timeago($(document));
  },

  toggleUnread: function(evt) {
    var note = $(evt.target).closest(".stream_element");
    var unread = note.hasClass("unread");

    if (unread){ this.setRead(note.data("guid")); }
    else { this.setUnread(note.data("guid")); }
  },

  getAllUnread: function(){ return $('.media.stream_element.unread'); },

  setRead: function(guid) { this.setUnreadStatus(guid, false); },

  setUnread: function(guid){ this.setUnreadStatus(guid, true); },

  setUnreadStatus: function(guid, state){
    $.ajax({
      url: "/notifications/" + guid,
      data: { set_unread: state },
      type: "PUT",
      context: this,
      success: this.clickSuccess
    });
  },

  clickSuccess: function(data) {
    var type = $('.stream_element[data-guid=' + data["guid"] + ']').data('type');
    this.updateView(data["guid"], type, data["unread"]);
  },

  markAllRead: function(evt){
    if(evt) { evt.preventDefault(); }
    var self = this;
    this.getAllUnread().each(function(i, el){
      self.setRead($(el).data("guid"));
    });
  },

  updateView: function(guid, type, unread) {
    var change = unread ? 1 : -1,
        all_notes = $('ul.nav > li:eq(0) .badge'),
        type_notes = $('ul.nav > li[data-type=' + type + '] .badge'),
        header_badge = $('#notification_badge .badge_count'),
        note = $('.stream_element[data-guid=' + guid + ']'),
        markAllReadLink = $('a#mark_all_read_link'),
        translationKey = unread ? 'notifications.mark_read' : 'notifications.mark_unread';

    if(unread){ note.removeClass("read").addClass("unread"); }
    else { note.removeClass("unread").addClass("read"); }

    $(".unread-toggle .entypo", note)
        .tooltip('destroy')
        .removeAttr("data-original-title")
        .attr('title',Diaspora.I18n.t(translationKey))
        .tooltip();

    [all_notes, type_notes, header_badge].forEach(function(element){
      element.text(function(i, text){
        return parseInt(text) + change });
    });

    [all_notes, type_notes].forEach(function(badge) {
      if(badge.text() > 0) {
        badge.addClass('badge-important').removeClass('badge-default');
      }
      else {
        badge.removeClass('badge-important').addClass('badge-default');
      }
    });

    if(header_badge.text() > 0){
      header_badge.removeClass('hidden');
      markAllReadLink.removeClass('disabled');
    }
    else{
      header_badge.addClass('hidden');
      markAllReadLink.addClass('disabled');
    }
  }
});
// @license-end
