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

  reshareAuthor : function(){
    return this.get("author");
  },

  createReshareUrl : "/reshares",

  reshare : function(){
    return this._reshare = this._reshare || new app.models.Reshare({root_guid : this.get("guid")});
  }
  
});
