app.models.Post = Backbone.Model.extend({
  urlRoot : "/posts",

  initialize : function() {
    this.setupCollections();
    this.bind("change", this.setupCollections, this)
  },

  setupCollections: function() {
    this.comments = new app.collections.Comments(this.get("comments") || this.get("last_three_comments"), {post : this});
    this.likes = this.likes || new app.collections.Likes([], {post : this}); // load in the user like initially
    this.participations = this.participations || new app.collections.Participations([], {post : this}); // load in the user like initially
  },

  createdAt : function() {
    return this.timeOf("created_at");
  },

  interactedAt : function() {
    return this.timeOf("interacted_at");
  },

  timeOf: function(field) {
    var timestamp = new Date(this.get(field)) /1000;

    if (isNaN(timestamp)) {
	timestamp = this.legacyTimeOf(field);
    }

    return timestamp;
  },

  legacyTimeOf: function(field) {
    var iso8601_utc_pattern = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(.(\d{3}))?Z$/;
    var time_components = this.get(field).match(iso8601_utc_pattern);
    var timestamp = 0;

    if (time_components != null) {
      if (time_components[8] == undefined) {
        time_components[8] = 0;
      }

      timestamp = Date.UTC(time_components[1], time_components[2] - 1, time_components[3],
                           time_components[4], time_components[5], time_components[6],
                           time_components[8]);
    }

    return timestamp /1000;
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
    var self = this;
    this.participations.create({}, {success : function(resp){
      self.set(resp)
      self.trigger('interacted', self)
    }});
  },

  unfollow : function() {
    var self = this;
    var participationModel = new app.models.Participation(this.get("user_participation"));
    participationModel.url = this.participations.url + "/" + participationModel.id;

    participationModel.destroy({success : function(model, resp){
      self.set(resp);
      self.trigger('interacted', this)
    }});
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
    var self = this;
    this.likes.create({}, {success : function(resp){
      self.set(resp)
      self.trigger('interacted', self)
    }});

  },

  unlike : function() {
    var self = this;
    var likeModel = new app.models.Like(this.get("user_like"));
    likeModel.url = this.likes.url + "/" + likeModel.id;

    likeModel.destroy({success : function(model, resp) {
      self.set(resp);
      self.trigger('interacted', this)
    }});
  }
});
