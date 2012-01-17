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

  reshare : function(){
    var reshare = new app.models.Reshare();
    reshare.save({root_guid : this.baseGuid()}, {
      success : function(){
        app.stream.collection.add(reshare.toJSON());
      }
    });
    return reshare;
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
    return +new Date(this.get("created_at")) / 1000;
  },

  baseGuid : function() {
    if(this.get("root")){
      return this.get("root").guid;
    } else {
      return this.get("guid");
    }
  },

  baseAuthor : function() {
    if(this.get("root")){
      return this.get("root").author;
    } else {
      return this.get("author");
    }
  },

  unlike : function() {
    var likeModel = new app.models.Like(this.get("user_like"));
    likeModel.url = this.likes.url + "/" + likeModel.id;

    likeModel.destroy();
    this.set({ user_like : null });
  },

  like : function() {
    this.set({ user_like : this.likes.create() });
  }
});
