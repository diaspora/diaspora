// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.models.Reshare = app.models.Post.extend({
  urlRoot : "/reshares",

  rootPost : function(){
    this._rootPost = this._rootPost || new app.models.Post(this.get("root"));
    return this._rootPost;
  },

  reshare : function(){
    return this.rootPost().reshare();
  },

  reshareAuthor : function(){
    return this.rootPost().reshareAuthor();
  }
});
// @license-end

