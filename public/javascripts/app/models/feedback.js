app.models.Feedback = Backbone.Model.extend({

  reshareAuthor : function(){
    return this.get("post").reshareAuthor();
  },

  reshare : function(){
    return this.get("post").reshare();
  },

  toggleLike : function() {
    var userLike = this.get("like");
    if(userLike) {
      this.doUnlike()
    } else {
      this.doLike()
    }
  },

  doLike : function() {
    this.set({ like : this.get('likes').create() });
  },

  doUnlike : function() {
    var likeModel = new app.models.Like(this.get("like"));
    console.log(likeModel);
    likeModel.url = this.get('likes').url + "/" + likeModel.id;

    likeModel.destroy();
    this.set({ like : null });
  },

  toggleFollow : function() {
    var userParticipation = this.get("participation");
    if(userParticipation) {
      this.unfollow();
    } else {
      this.follow();
    }
  },

  follow : function() {
    this.set({ participation : this.get("participations").create() });
  },

  unfollow : function() {
    var participationModel = new app.models.Participation(this.get("participation"));
    participationModel.url = this.get("participations").url + "/" + participationModel.id;

    participationModel.destroy();
    this.set({ participation : null });
  }
});
