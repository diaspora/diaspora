// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.SinglePostInteractionCounts = app.views.Base.extend({
  templateName: "single-post-viewer/single-post-interaction-counts",
  tooltipSelector: ".avatar.micro",

  events: {
    "click #show-all-likes": "showAllLikes",
    "click #show-all-reshares": "showAllReshares"
  },

  initialize: function() {
    this.model.interactions.on("change", this.render, this);
    this.model.interactions.likes.on("change", this.render, this);
    this.model.interactions.reshares.on("change", this.render, this);
  },

  presenter: function() {
    var interactions = this.model.interactions;
    return {
      likes: interactions.likes.toJSON(),
      reshares: interactions.reshares.toJSON(),
      commentsCount: interactions.commentsCount(),
      likesCount: interactions.likesCount(),
      resharesCount: interactions.resharesCount(),
      showMoreLikes: interactions.likes.length < interactions.likesCount(),
      showMoreReshares: interactions.reshares.length < interactions.resharesCount()
    };
  },

  _showAll: function(interactionType, models) {
    this.$("#show-all-" + interactionType).addClass("hidden");
    this.$("#" + interactionType + " .loader").removeClass("hidden");
    models.fetch({success: function() {
      models.trigger("change");
    }});
  },

  showAllLikes: function(evt) {
    evt.preventDefault();
    this._showAll("likes", this.model.interactions.likes);
  },

  showAllReshares: function(evt) {
    evt.preventDefault();
    this._showAll("reshares", this.model.interactions.reshares);
  }
});
// @license-end
