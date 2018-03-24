// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
//= require ./publisher/mention_view

app.views.CommentMention = app.views.PublisherMention.extend({
  initialize: function(opts) {
    opts.url = Routes.mentionablePost(opts.postId);
    app.views.PublisherMention.prototype.initialize.call(this, opts);
  }
});
// @license-end
