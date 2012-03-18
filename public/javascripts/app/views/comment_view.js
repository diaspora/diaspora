app.views.Comment = app.views.Content.extend({

  templateName: "comment",

  className : "comment media",

  events : function() {
    return _.extend(app.views.Content.prototype.events, {
      "click .comment_delete": "destroyModel"
    });
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      canRemove: this.canRemove(),
      text : app.helpers.textFormatter(this.model)
    })
  },

  ownComment : function() {
    return app.currentUser.authenticated() && this.model.get("author").diaspora_id == app.currentUser.get("diaspora_id")
  },

  postOwner : function() {
    return  app.currentUser.authenticated() && this.model.get("parent").author.diaspora_id == app.currentUser.get("diaspora_id")
  },

  canRemove : function() {
    return app.currentUser.authenticated() && (this.ownComment() || this.postOwner())
  }
});
