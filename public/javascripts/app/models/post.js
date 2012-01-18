app.models.Post = Backbone.Model.extend({
  initialize : function() {
    this.comments = new app.collections.Comments(this.get("last_three_comments"));
    this.comments.url = this.url() + '/comments';

    this.likes = new app.collections.Likes(this.get("user_like")); // load in the user like initially
    this.likes.url = this.url() + '/likes';
  },

  url : function() {
    if(this.id) {
      return "/posts/" + this.id;
    } else {
      return "/posts"
    }
  },

  reshareUrl : "/reshares",
  reshare : function(){
    return this._reshare = this._reshare || new app.models.Reshare({root_guid : this.get("guid")});
  },

  reshareAuthor : function(){
    return this.get("author")
  },

  toggleLike : function() {
    var userLike = this.get("user_like")
    if(userLike) {
      this.unlike()
    } else {
      this.like()
    }
  },

  createdAt : function() {
    return new Date(this.get("created_at")) / 1000;
  },


  likeUrl : function(){
    return this.url() + "/likes"
  },

  like : function() {
    this.set({ user_like : this.likes.create({}, {url : this.likeUrl()}) });
  },

  unlike : function() {
    var likeModel = new app.models.Like(this.get("user_like"));
    likeModel.url = this.likes.url + "/" + likeModel.id;

    likeModel.destroy();
    this.set({ user_like : null });
  }
});
