app.views.Comment = app.views.StreamObject.extend({

  template_name: "#comment-template",

  tagName : "li",

  className : "comment loaded",

  events : {
    "click .comment_delete": "destroyModel"
  },

  initialize : function() {
    $(this.el).attr("id", this.model.get("guid"));

    return this;
  },

  postRenderTemplate : function(){
    this.$("time").timeago();
  }
});
