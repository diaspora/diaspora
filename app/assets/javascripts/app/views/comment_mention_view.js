//= require ./publisher/mention_view

app.views.CommentMention = app.views.PublisherMention.extend({
  initialize: function(opts) {
    opts.url = Routes.mentionablePost(opts.postId);
    app.views.PublisherMention.prototype.initialize.call(this, opts);
  }
});
