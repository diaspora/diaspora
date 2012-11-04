app.collections.TagFollowings = Backbone.Collection.extend({

  model: app.models.TagFollowing,

  url : "/tag_followings",

  create : function(model) {
    var name = model.name || model.get("name");
    if(!this.any(
        function(tagFollowing){
          return tagFollowing.get("name") === name; 
        })) {
      Backbone.Collection.prototype.create.apply(this, arguments);
    }
  }

});
