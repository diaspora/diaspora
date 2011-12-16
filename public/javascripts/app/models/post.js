App.Models.Post = Backbone.Model.extend({
  initialize: function() {
    this.comments = new App.Collections.Comments(this.get("last_three_comments"));
    this.comments.url = this.url() + '/comments';

    this.likes = new App.Collections.Likes(this.get("user_like")); // load in the user like initially
    this.likes.url = this.url() + '/likes';
  },

  url: function(){
    return "/posts/" + this.id;
  },

  createdAt: function(){
    return +new Date(this.get("created_at")) / 1000;
  }
});
