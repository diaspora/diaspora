app.models.Post = Backbone.Model.extend(_.extend({}, app.models.formatDateMixin, {
  urlRoot : "/posts",

  initialize : function() {
    this.interactions = new app.models.Post.Interactions(_.extend({post : this}, this.get("interactions")))
    this.delegateToInteractions()
  },

  delegateToInteractions : function(){
    this.comments = this.interactions.comments
    this.likes = this.interactions.likes

    this.comment = function(){
      this.interactions.comment.apply(this.interactions, arguments)
    }
  },

  setFrameName : function(){
    this.set({frame_name : new app.models.Post.TemplatePicker(this).getFrameName()})
  },

  applicableTemplates: function() {
    return new app.models.Post.TemplatePicker(this).applicableTemplates()
  },

  interactedAt : function() {
    return this.timeOf("interacted_at");
  },

  reshare : function(){
    return this._reshare = this._reshare || new app.models.Reshare({root_guid : this.get("guid")});
  },

  reshareAuthor : function(){
    return this.get("author")
  },

  toggleFavorite : function(options){
    this.set({favorite : !this.get("favorite")})

    /* guard against attempting to save a model that a user doesn't own */
    if(options.save){ this.save() }
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
  },

  //returns a promise
  preloadOrFetch : function(){
    var action = app.hasPreload("post") ? this.set(app.parsePreload("post")) : this.fetch()
    return $.when(action)
  },

  hasPhotos : function(){
    return this.get("photos") && this.get("photos").length > 0
  },

  hasText : function(){
    return $.trim(this.get("text")) !== ""
  }
}), {
  headlineLimit : 118,

  frameMoods : [
    "Wallpaper",
    "Vanilla",
    "Typist",
    "Fridge"
  ]
});
