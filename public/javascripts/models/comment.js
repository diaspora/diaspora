App.Models.Comment = Backbone.Model.extend({
  url: function() {
    return "/posts/" + this.get("post_id") + "/comments";
  }
});
