app.views.Photo = app.views.Base.extend({

  templateName: "photo",

  className : "photo loaded",

  events: {
    "click .remove_post": "destroyModel"
  },

  tooltipSelector : ".block_user, .delete",

  initialize : function() {
    $(this.el).attr("id", this.model.get("guid"));
    this.model.bind('remove', this.remove, this);
    return this;
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : app.currentUser.isAuthorOf(this.model),
    });
  }
});
