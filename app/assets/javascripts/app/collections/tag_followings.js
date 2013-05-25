app.collections.TagFollowings = Backbone.Collection.extend({

  model: app.models.TagFollowing,
  url : "/tag_followings",
  comparator: function(first_tf, second_tf) {
    return  -first_tf.get("name").localeCompare(second_tf.get("name"));
  },

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
