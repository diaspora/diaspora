app.views.Comment = app.views.Content.extend({

  templateName: "comment",

  tagName : "li",

  className : "comment",

  events : {
    "click .comment_delete": "destroyModel"
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      ownComment: this.ownComment(),
      text : app.helpers.textFormatter(this.model)
    })
  },

  ownComment: function() {
    if(!app.user()){ return false }
    return this.model.get("author").diaspora_id == app.user().diaspora_id
  }
});
