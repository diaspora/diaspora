// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.TagFollowing = app.views.Base.extend({

  templateName: "tag_following",

  className : "hoverable",

  tagName: "li",

  events : {
    "click .delete-tag-following": "destroyModel"
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
    });
  }

});
// @license-end
