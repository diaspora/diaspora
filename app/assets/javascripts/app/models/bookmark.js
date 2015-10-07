app.models.Bookmark = Backbone.Model.extend({
  baseURL: "/posts/",
  url: function() { return this.baseURL + '/' + this.id + '/bookmarks'; }
});
