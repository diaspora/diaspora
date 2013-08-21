app.views.SinglePostContent = app.views.Base.extend({
  templateName: 'single-post-viewer/single-post-content',

  subviews : {
    "#single-post-actions" : "singlePostActionsView",
    '#real-post-content' : 'postContentView',
    ".oembed" : "oEmbedView",
    ".opengraph" : "openGraphView",
    ".status-message-location" : "postLocationStreamView"
  },

  initialize : function() {
    this.singlePostActionsView = new app.views.SinglePostActions({model: this.model});
    this.oEmbedView = new app.views.OEmbed({model : this.model});
    this.openGraphView = new app.views.OpenGraph({model : this.model});
    this.postContentView = new app.views.ExpandedStatusMessage({model: this.model});
  },

  postLocationStreamView : function(){
    return new app.views.LocationStream({ model : this.model});
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : this.authorIsCurrentUser(),
      showPost : this.showPost(),
      text : app.helpers.textFormatter(this.model.get("text"), this.model)
    })
  },

  authorIsCurrentUser : function() {
    return app.currentUser.authenticated() && this.model.get("author").id == app.user().id
  },

  showPost : function() {
    return (app.currentUser.get("showNsfw")) || !this.model.get("nsfw")
  }
});
