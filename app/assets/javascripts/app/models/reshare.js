app.models.Reshare = app.models.Post.extend({
  urlRoot : "/reshares",

  rootPost : function(){
    this._rootPost = this._rootPost || new app.models.Post(this.get("root"));
    return this._rootPost
  },

  reshare : function(){
    return this.rootPost().reshare()
  },

  reshareAuthor : function(){
    return this.rootPost().reshareAuthor()
  }
});
