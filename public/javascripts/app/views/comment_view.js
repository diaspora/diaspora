app.views.Comment = app.views.StreamObject.extend({

  template_name: "#comment-template",

  events : {
    "click .comment_delete": "destroyModel"
  },

  postRenderTemplate : function(){
    this.$("time").timeago();
  }
});
