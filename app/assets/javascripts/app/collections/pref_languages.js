app.collections.PrefLanguages = Backbone.Collection.extend({

  model: app.models.prefered_language,
  url : "/preferedlang",
  comparator: function(first_tf, second_tf) {
    return  -first_tf.get("name").localeCompare(second_tf.get("name"));
  },

  create : function(model) {
    var name = model.name || model.get("name");
    if(!this.any(
        function(prefLanguage){
          return prefLanguage.get("name") === name; 
        })) {
      Backbone.Collection.prototype.create.apply(this, arguments);
    }
  }

});
