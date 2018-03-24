// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Notifications = Backbone.View.extend({
  events: {
    "click .unread-toggle": "toggleUnread",
    "click #mark-all-read-link": "markAllRead"
  },

  initialize: function() {
    $(".unread-toggle .entypo-eye").tooltip();
    app.helpers.timeago($(document));
    this.bindCollectionEvents();
  },

  bindCollectionEvents: function() {
    this.collection.on("change", this.onChangedUnreadStatus.bind(this));
    this.collection.on("update", this.updateView.bind(this));
  },

  toggleUnread: function(evt) {
    var note = $(evt.target).closest(".stream-element");
    var unread = note.hasClass("unread");
    var guid = note.data("guid");
    if (unread) {
      this.collection.setRead(guid);
    } else {
      this.collection.setUnread(guid);
    }
  },

  markAllRead: function(evt) {
    evt.preventDefault();
    this.collection.setAllRead();
  },

  onChangedUnreadStatus: function(model) {
    var unread = model.get("unread");
    var translationKey = unread ? "notifications.mark_read" : "notifications.mark_unread";
    var note = $(".stream-element[data-guid=" + model.guid + "]");

    note.find(".entypo-eye")
      .tooltip("destroy")
      .removeAttr("data-original-title")
      .attr("title", Diaspora.I18n.t(translationKey))
      .tooltip();

    if (unread) {
      note.removeClass("read").addClass("unread");
    } else {
      note.removeClass("unread").addClass("read");
    }
  },

  updateView: function() {
    var notificationsContainer = $("#notifications_container");

    // update notification counts in the sidebar
    Object.keys(this.collection.unreadCountByType).forEach(function(notificationType) {
      var count = this.collection.unreadCountByType[notificationType];
      this.updateBadge(notificationsContainer.find("a[data-type=" + notificationType + "] .badge"), count);
    }.bind(this));

    this.updateBadge(notificationsContainer.find("a[data-type=all] .badge"), this.collection.unreadCount);

    // update notification count in the header
    this.updateBadge($(".notifications-link .badge"), this.collection.unreadCount);

    var markAllReadLink = $("a#mark-all-read-link");

    if (this.collection.unreadCount > 0) {
      markAllReadLink.removeClass("disabled");
    } else {
      markAllReadLink.addClass("disabled");
    }
  },

  updateBadge: function(badge, count) {
    badge.text(count);
    if (count > 0) {
      badge.removeClass("hidden");
    } else {
      badge.addClass("hidden");
    }
  }
});
// @license-end
