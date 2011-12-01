var App = {
  Collections: {},
  Models: {},
  Views: {},

  currentUser: function() {
    return $.parseJSON(unescape($("body").data("current-user-metadata")));
  }
};
