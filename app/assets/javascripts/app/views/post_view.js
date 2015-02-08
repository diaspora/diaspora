// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Post = app.views.Base.extend({
  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : app.currentUser.isAuthorOf(this.model), 
      showPost : this.showPost(),
      text : app.helpers.textFormatter(this.model.get("text"), this.model.get("mentioned_people"))
    });
  },

  showPost : function() {
    return (app.currentUser.get("showNsfw")) || !this.model.get("nsfw");
  }
});
// @license-end
