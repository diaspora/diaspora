App.Views.StreamObject = Backbone.View.extend({
  initialize: function(options) {
    this.model = options.model;
    this.model.bind('remove', this.remove, this);
    this.model.bind('change', this.render, this);
  },

  destroyModel: function(evt){
    if(evt){ evt.preventDefault(); }
    this.model.destroy();
  },

  remove: function() {
    $(this.el).remove();
  },

  context : function(){
    var modelJson = this.model ? this.model.toJSON() : {}
    return $.extend(modelJson, App.user());
  },

  renderTemplate : function(){
    this.template = _.template($(this.template_name).html());
    $(this.el).html(this.template(this.context()));
    return this;
  },

  render : function() {
    return this.renderTemplate()
  }
});
