app.views.Post = app.views.Base.extend({
  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : app.currentUser.isAuthorOf(this.model), 
      showPost : this.showPost(),
      text : app.helpers.textFormatter(this.model.get("text"), this.model)
    })
  },

  showPost : function() {
    return (app.currentUser.get("showNsfw")) || !this.model.get("nsfw")
  }
});
