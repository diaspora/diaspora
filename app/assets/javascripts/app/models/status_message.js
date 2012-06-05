app.models.StatusMessage = app.models.Post.extend({
  url : function(){
    return this.isNew() ? '/status_messages' : '/posts/' + this.get("id");
  },

  defaults : {
    'post_type' : 'StatusMessage',
    'author' : app.currentUser ? app.currentUser.attributes : {}
  },

  toJSON : function(){
    return {
      status_message : _.clone(this.attributes),
      aspect_ids : this.get("aspect_ids"),
      photos : this.photos && this.photos.pluck("id"),
      services : this.get("services")
    }
  }
});
