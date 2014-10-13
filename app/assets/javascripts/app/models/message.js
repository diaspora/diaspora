app.models.Message = Backbone.Model.extend({

  initialize: function() {
    // Make this Message draftable
    Backbone.Draftable.call(this);
  }

});

