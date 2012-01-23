app.views.Comment = app.views.Content.extend({

  legacyTemplate : true,
  template_name: "#comment-template",

  tagName : "li",

  className : "comment",

  events : {
    "click .comment_delete": "destroyModel"
  },

  initialize : function() {
    $(this.el).attr("id", this.model.get("guid"));

    return this;
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {ownComment: this.ownComment()})
  },

  ownComment: function() {
    if(!app.user()){ return false }
    return this.model.get("author").diaspora_id == app.user().diaspora_id
  }
});
