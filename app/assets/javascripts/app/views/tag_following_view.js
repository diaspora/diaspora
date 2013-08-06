app.views.TagFollowing = app.views.Base.extend({

  templateName: "tag_following",

  className : "hoverable",

  tagName: "li",

  events : {
    "click .delete_tag_following": "destroyModel"
  },

  initialize : function(){
    this.el.id = "tag-following-" + this.model.get("name");
    this.model.bind("destroy", this.hide, this);
  },

  hide : function() {
    this.$el.slideUp();
  },

  postRenderTemplate : function() {
    this.$el.hide();
    this.$el.slideDown();
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      tag : this.model
    })
  }
  
});
