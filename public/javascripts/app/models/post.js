app.models.Post = Backbone.Model.extend({
  urlRoot : "/posts",
  initialize : function() {
    this.comments = new app.collections.Comments(this.get("last_three_comments"), {post : this});
    this.likes = new app.collections.Likes([], {post : this}); // load in the user like initially
    this.participations = new app.collections.Participations([], {post : this}); // load in the user like initially
  },

  createdAt : function() {
    return this.timeOf("created_at");
  },

  interactedAt : function() {
    return this.timeOf("interacted_at");
  },

  timeOf: function(field) {
    return new Date(this.get(field)) /1000;
  },

  createReshareUrl : "/reshares",

  reshare : function(){
    return this._reshare = this._reshare || new app.models.Reshare({root_guid : this.get("guid")});
  },

  reshareAuthor : function(){
    return this.get("author")
  },

  toggleFollow : function() {
    var userParticipation = this.get("user_participation");
    if(userParticipation) {
      this.unfollow();
    } else {
      this.follow();
    }
  },

  follow : function() {
    this.set({ user_participation : this.participations.create() });
  },

  unfollow : function() {
    var participationModel = new app.models.Participation(this.get("user_participation"));
    participationModel.url = this.participations.url + "/" + participationModel.id;

    participationModel.destroy();
    this.set({ user_participation : null });
  },

  toggleLike : function() {
    var userLike = this.get("user_like")
    if(userLike) {
      this.unlike()
    } else {
      this.like()
    }
  },

  like : function() {
    this.set({ user_like : this.likes.create() });
  },

  unlike : function() {
    var likeModel = new app.models.Like(this.get("user_like"));
    likeModel.url = this.likes.url + "/" + likeModel.id;

    likeModel.destroy();
    this.set({ user_like : null });
  }
});
