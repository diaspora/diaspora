app.models.Photo = Backbone.Model.extend({
  urlRoot : "/photos",

  initialize : function() {},

  createdAt : function() {
    return this.timeOf("created_at");
  },

  timeOf: function(field) {
    return new Date(this.get(field)) /1000;
  },

});