app.models.Post = Backbone.Model.extend({
  initialize: function() {
    this.comments = new app.collections.Comments(this.get("last_three_comments"));
    this.comments.url = this.url() + '/comments';

    this.likes = new app.collections.Likes(this.get("user_like")); // load in the user like initially
    this.likes.url = this.url() + '/likes';
  },

  url: function(){
    if(this.id) {
      return "/posts/" + this.id;
    } else {
      return "/status_messages"
    }
  },

  createdAt: function(){
    return +new Date(this.get("created_at")) / 1000;
  }
});
