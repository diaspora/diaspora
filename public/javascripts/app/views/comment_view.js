app.views.Comment = app.views.Content.extend({

  template_name: "#comment-template",

  tagName : "li",

  className : "comment",

  events : {
    "click .comment_delete": "destroyModel"
  },

  initialize : function() {
    $(this.el).attr("id", this.model.get("guid"));

    return this;
  }
});
