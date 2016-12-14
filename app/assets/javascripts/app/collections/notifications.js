app.collections.Notifications = Backbone.Collection.extend({
  model: app.models.Notification,
  // URL parameter
  /* eslint-disable camelcase */
  url: Routes.notifications({per_page: 10, page: 1}),
  /* eslint-enable camelcase */
  page: 2,
  perPage: 5,
  unreadCount: 0,
  unreadCountByType: {},
  timeout: 300000, // 5 minutes

  initialize: function() {
    this.fetch();
    setInterval(this.pollNotifications.bind(this), this.timeout);
    Diaspora.BrowserNotification.requestPermission();
  },

  pollNotifications: function() {
    var unreadCountBefore = this.unreadCount;
    this.fetch();

    this.once("finishedLoading", function() {
      if (unreadCountBefore < this.unreadCount) {
        Diaspora.BrowserNotification.spawnNotification(
          Diaspora.I18n.t("notifications.new_notifications", {count: this.unreadCount}));
      }
    }, this);
  },

  fetch: function(options) {
    options = options || {};
    options.remove = false;
    options.merge = true;
    options.parse = true;
    Backbone.Collection.prototype.fetch.apply(this, [options]);
  },

  fetchMore: function() {
    var hasMoreNotifications = (this.page * this.perPage) <= this.length;
    // There are more notifications to load on the current page
    if (hasMoreNotifications) {
      this.page++;
      // URL parameter
      /* eslint-disable camelcase */
      var route = Routes.notifications({per_page: this.perPage, page: this.page});
      /* eslint-enable camelcase */
      this.fetch({url: route, pushBack: true});
    }
  },

  /**
   * Adds new models to the collection at the end or at the beginning of the collection and
   * then fires an event for each model of the collection. It will fire a different event
   * based on whether the models were added at the end (typically when the scroll triggers to load more
   * notifications) or at the beginning (new notifications have been added to the front of the list).
   */
  set: function(items, options) {
    options = options || {};
    options.at = options.pushBack ? this.length : 0;

    // Retreive back the new created models
    var models = [];
    var accu = function(model) { models.push(model); };
    this.on("add", accu);
    Backbone.Collection.prototype.set.apply(this, [items, options]);
    this.off("add", accu);

    if (options.pushBack) {
      models.forEach(function(model) { this.trigger("pushBack", model); }.bind(this));
    } else {
      // Fires events in the reverse order so that the first event is prepended in first position
      models.reverse();
      models.forEach(function(model) { this.trigger("pushFront", model); }.bind(this));
    }
    this.trigger("finishedLoading");
  },

  parse: function(response) {
    this.unreadCount = response.unread_count;
    this.unreadCountByType = response.unread_count_by_type;

    return _.map(response.notification_list, function(item) {
      /* eslint-disable new-cap */
      var model = new this.model(item);
      /* eslint-enable new-cap */
      model.on("userChangedUnreadStatus", this.onChangedUnreadStatus.bind(this));
      model.on("change:unread", function() { this.trigger("update"); }.bind(this));
      return model;
    }.bind(this));
  },

  setAllRead: function() {
    this.forEach(function(model) { model.setRead(); });
  },

  setRead: function(guid) {
    this.find(function(model) { return model.guid === guid; }).setRead();
  },

  setUnread: function(guid) {
    this.find(function(model) { return model.guid === guid; }).setUnread();
  },

  onChangedUnreadStatus: function(model) {
    if (model.get("unread") === true) {
      this.unreadCount++;
      this.unreadCountByType[model.get("type")]++;
    } else {
      this.unreadCount = Math.max(this.unreadCount - 1, 0);
      this.unreadCountByType[model.get("type")] = Math.max(this.unreadCountByType[model.get("type")] - 1, 0);
    }
    this.trigger("update");
  }
});
