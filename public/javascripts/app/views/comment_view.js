App.Views.Comment = App.Views.StreamObject.extend({

  template_name: "#comment-template",

  events : {
    "click .comment_delete": "destroyModel"
  }
});
