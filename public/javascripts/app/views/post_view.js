app.views.Post = app.views.StreamObject.extend({
  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : this.authorIsCurrentUser(),
      showPost : this.showPost(),
      text : app.helpers.textFormatter(this.model)
    })
  },

  authorIsCurrentUser : function() {
    return app.currentUser.authenticated() && this.model.get("author").id == app.user().id
  },

  showPost : function() {
    return (app.currentUser.get("showNsfw")) || !this.model.get("nsfw")
  }
}, { //static methods below

  showFactory : function(model) {
    var frameName = model.get("frame_name");

    if(_.include(app.models.Post.legacyTemplateNames, frameName)){
      return legacyShow(model)
    } else {
      return new app.views.Post[frameName]({
        model : model
      })
    }

    function legacyShow(model) {
      return new app.views.Post.Legacy({
        model : model,
        className :   frameName + " post loaded",
        templateName : "post-viewer/content/" +  frameName
      });
    }
  }
});

app.views.Post.Legacy = app.views.Post.extend({
  initialize : function(options) {
    this.templateName = options.templateName || this.templateName
  }
})