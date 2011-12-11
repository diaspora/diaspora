App.Models.Post = Backbone.Model.extend({
  url: "/posts",

  initialize: function() {
    this.comments = new App.Collections.Comments(this.get("last_three_comments"));
  },

  createdAt: function(){
    return +new Date(this.get("created_at")) / 1000;
  }
});
