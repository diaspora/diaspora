app.models.Conversation = Backbone.Model.extend({
  urlRoot: '/conversations',

  initialize: function() {
    console.log(this);
  }
});
