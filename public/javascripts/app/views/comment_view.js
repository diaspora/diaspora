app.views.Comment = app.views.Content.extend({

  templateName: "comment",

  className : "comment",

  events : {
    "click .comment_delete": "destroyModel"
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      canRemove: this.canRemove(),
      text : app.helpers.textFormatter(this.model)
    })
  },

  ownComment : function() {
    return this.model.get("author").diaspora_id == app.user().diaspora_id
  },

  postOwner : function() {
    return this.model.get("parent").author.diaspora_id == app.user().diaspora_id
  },

  canRemove : function() {
    if(!app.user()){ return false }
    return this.ownComment() || this.postOwner()
  }
});
