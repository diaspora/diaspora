// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

//= require ./content_view
app.views.Comment = app.views.Content.extend({
  templateName: "comment",
  className : "comment media",
  tooltipSelector: "time",

  events : function() {
    return _.extend({}, app.views.Content.prototype.events, {
      "click .comment_delete": "destroyModel",
      "click .comment_report": "report"
    });
  },

  initialize : function(options){
    this.templateName = options.templateName || this.templateName;
    this.model.on("change", this.render, this);
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      canRemove: this.canRemove(),
      text: app.helpers.textFormatter(this.model.get("text"), this.model.get("mentioned_people"))
    });
  },

  ownComment : function() {
    return app.currentUser.authenticated() && this.model.get("author").diaspora_id === app.currentUser.get("diaspora_id");
  },

  postOwner : function() {
    return  app.currentUser.authenticated() && this.model.get("parent").author.diaspora_id === app.currentUser.get("diaspora_id");
  },

  canRemove : function() {
    return app.currentUser.authenticated() && (this.ownComment() || this.postOwner());
  }
});

app.views.ExpandedComment = app.views.Comment.extend({
  postRenderTemplate : function(){
    this.bindMediaEmbedThumbClickEvent();
  }
});
// @license-end
