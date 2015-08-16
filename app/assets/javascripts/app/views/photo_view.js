// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Photo = app.views.Base.extend({

  templateName: "photo",

  className : "photo loaded col-md-4 col-sm-6 clearfix",

  events: {
    "click .remove_post": "destroyModel"
  },

  tooltipSelector : ".control-icons a",

  initialize : function() {
    $(this.el).attr("id", this.model.get("guid"));
    return this;
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : app.currentUser.isAuthorOf(this.model)
    });
  }
});
// @license-end

