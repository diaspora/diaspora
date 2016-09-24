// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Notifications = Backbone.View.extend({

  events: {
    "click .unread-toggle" : "toggleUnread",
    "click #mark_all_read_link": "markAllRead"
  },

  initialize: function() {
    $(".unread-toggle .entypo-eye").tooltip();
    app.helpers.timeago($(document));
  },

  toggleUnread: function(evt) {
    var note = $(evt.target).closest(".stream-element");
    var unread = note.hasClass("unread");
    var guid = note.data("guid");
    if (unread){ this.setRead(guid); }
    else { this.setUnread(guid); }
  },

  getAllUnread: function() { return $(".media.stream-element.unread"); },

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
    var guid = data.guid;
    var type = $(".stream-element[data-guid=" + guid + "]").data("type");
    this.updateView(guid, type, data.unread);
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
        allNotes = $("#notifications_container .list-group > a:eq(0) .badge"),
        typeNotes = $("#notifications_container .list-group > a[data-type=" + type + "] .badge"),
        headerBadge = $(".notifications-link .badge"),
        note = $(".notifications .stream-element[data-guid=" + guid + "]"),
        markAllReadLink = $("a#mark_all_read_link"),
        translationKey = unread ? "notifications.mark_read" : "notifications.mark_unread";

    if(unread){ note.removeClass("read").addClass("unread"); }
    else { note.removeClass("unread").addClass("read"); }

    $(".unread-toggle .entypo-eye", note)
        .tooltip("destroy")
        .removeAttr("data-original-title")
        .attr("title",Diaspora.I18n.t(translationKey))
        .tooltip();

    [allNotes, typeNotes, headerBadge].forEach(function(element){
      element.text(function(i, text){
        return parseInt(text) + change;
      });
    });

    [allNotes, typeNotes].forEach(function(badge) {
      if(badge.text() > 0) {
        badge.removeClass("hidden");
      }
      else {
        badge.addClass("hidden");
      }
    });

    if(headerBadge.text() > 0){
      headerBadge.removeClass("hidden");
      markAllReadLink.removeClass("disabled");
    }
    else{
      headerBadge.addClass("hidden");
      markAllReadLink.addClass("disabled");
    }
  }
});
// @license-end
