// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.SinglePostInteractions = app.views.Base.extend({
  templateName: "single-post-viewer/single-post-interactions",
  className: "framed-content",

  subviews: {
    "#comments": "commentStreamView",
    "#interaction-counts": "interactionCountsView"
  },

  commentStreamView: function() {
    return new app.views.SinglePostCommentStream({model: this.model});
  },

  interactionCountsView: function() {
    return new app.views.SinglePostInteractionCounts({model: this.model});
  }
});
// @license-end
