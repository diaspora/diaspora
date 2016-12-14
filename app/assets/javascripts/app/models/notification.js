app.models.Notification = Backbone.Model.extend({
  constructor: function(attributes, options) {
    options = options || {};
    options.parse = true;
    Backbone.Model.apply(this, [attributes, options]);
    this.guid = this.get("id");
  },

  /**
   * Flattens the notification object returned by the server.
   *
   * The server returns an object that looks like:
   *
   * {
   *   "reshared": {
   *     "id": 45,
   *     "target_type": "Post",
   *     "target_id": 11,
   *     "recipient_id": 1,
   *     "unread": true,
   *     "created_at": "2015-10-27T19:56:30.000Z",
   *     "updated_at": "2015-10-27T19:56:30.000Z",
   *     "note_html": <html/>
   *   },
   *  "type": "reshared"
   * }
   *
   * The returned object looks like:
   *
   * {
   *   "type": "reshared",
   *   "id": 45,
   *   "target_type": "Post",
   *   "target_id": 11,
   *   "recipient_id": 1,
   *   "unread": true,
   *   "created_at": "2015-10-27T19:56:30.000Z",
   *   "updated_at": "2015-10-27T19:56:30.000Z",
   *   "note_html": <html/>,
   * }
   */
  parse: function(response) {
    if (response.id) {
      // already correct format
      return response;
    }
    var result = {type: response.type};
    result = $.extend(result, response[result.type]);
    return result;
  },

  setRead: function() {
    this.setUnreadStatus(false);
  },

  setUnread: function() {
    this.setUnreadStatus(true);
  },

  setUnreadStatus: function(state) {
    if (this.get("unread") !== state) {
      $.ajax({
        url: Routes.notification(this.guid),
        /* eslint-disable camelcase */
        data: {set_unread: state},
        /* eslint-enable camelcase */
        type: "PUT",
        context: this,
        success: function() {
          this.set("unread", state);
          this.trigger("userChangedUnreadStatus", this);
        }
      });
    }
  }
});
