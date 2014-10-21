// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
// @license-end

