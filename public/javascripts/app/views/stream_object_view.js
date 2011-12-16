App.Views.StreamObject = Backbone.View.extend({
  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($(this.template_name).html());

    this.model.bind('remove', this.remove, this);
  },

  destroyModel: function(evt){
    if(evt){ evt.preventDefault(); }
    this.model.destroy();
  },

  remove: function() {
    $(this.el).remove();
  }
});
