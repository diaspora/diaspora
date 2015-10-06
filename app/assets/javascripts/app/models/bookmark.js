app.models.Bookmark = Backbone.Model.extend({
  initialize: function(options) {
    this.type = options.type;
    this.urlRoot = '/posts/' + options.bookmark.post_id + '/bookmarks';
  }
});
