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
    return app.helpers.dateFormatter.parse(this.get(field)) / 1000;
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
  },

  comment : function (text) {

    var self = this
      , postComments = this.comments;

    postComments.create({"text": text}, {
      url : postComments.url(),
      wait:true, // added a wait for the time being.  0.5.3 was not optimistic, but 0.9.2 is.
      error:function () {
        alert(Diaspora.I18n.t("failed_to_post_message"));
      }
    });
  },

  headline : function() {
    var headline = this.get("text").trim()
      , newlineIdx = headline.indexOf("\n")
    return (newlineIdx > 0 ) ? headline.substr(0, newlineIdx) : headline
  },

  body : function(){
    var body = this.get("text").trim()
      , newlineIdx = body.indexOf("\n")
    return (newlineIdx > 0 ) ? body.substr(newlineIdx+1, body.length) : ""
  }
}, {
  headlineLimit : 118,

  frameMoods : [
    "Day",
    "Night",
    "Wallpaper",
    "Newspaper"
  ],

  legacyTemplateNames : [
    "status-with-photo-backdrop",
    "note",
    "rich-media",
    "multi-photo",
    "photo-backdrop",
    "activity-streams-photo",
    "status"
  ]
});
