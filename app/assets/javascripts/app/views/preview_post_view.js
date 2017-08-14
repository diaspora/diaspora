// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.PreviewPost = app.views.Post.extend({
  templateName: "stream-element",
  className: "stream-element loaded",

  subviews: {
    ".post-content": "postContentView",
    ".oembed": "oEmbedView",
    ".opengraph": "openGraphView",
    ".poll": "pollView",
    ".status-message-location": "postLocationStreamView"
  },

  initialize: function() {
    this.model.set("preview", true);
    this.oEmbedView = new app.views.OEmbed({model: this.model});
    this.openGraphView = new app.views.OpenGraph({model: this.model});
    this.pollView = new app.views.Poll({model: this.model});
  },

  postContentView: function() {
    return new app.views.StatusMessage({model: this.model});
  },

  postLocationStreamView: function() {
    return new app.views.LocationStream({model: this.model});
  }
});
// @license-end
