App.Views.StreamObject = Backbone.View.extend({
  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($(this.template_name).html());
  },

  destroyModel: function(evt){
    if(evt){ evt.preventDefault(); }

    var domElement = this.el;
    this.model.destroy({
      success: function(){
        $(domElement).remove();
      }
    });
  }
});
