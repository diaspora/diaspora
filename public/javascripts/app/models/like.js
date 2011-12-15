App.Models.Like = Backbone.Model.extend({
  url: function(){
    if(this.get("id")) {
      return "/" + this.get("target_type") + "s/" + this.get("target_id") + "/likes/" + this.get("id");
    }
    else {
      return "/posts/" + this.get("target_id") + "/likes";
    }
  }
})
