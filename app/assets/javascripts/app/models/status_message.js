// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
      services : this.get("services"),
      poll : this.get("poll")
    };
  }
});
// @license-end
