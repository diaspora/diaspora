app.views.TagFollowing = app.views.Base.extend({

  templateName: "tag_following",

  className : "unfollow",

  tagName: "li",

  events : {
    "click .tag_following_delete": "destroyModel"
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