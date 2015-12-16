// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
// @license-end

