App.Views.StreamObject = Backbone.View.extend({
  initialize: function(options) {
    this.model.bind('remove', this.remove, this);
    this.model.bind('change', this.render, this);
  },

  destroyModel: function(evt){
    if(evt){ evt.preventDefault(); }
    this.model.destroy();
  },

  presenter : function(){
    return this.defaultPresenter()
  },

  defaultPresenter : function(){
    var modelJson = this.model ? this.model.toJSON() : {}
    return _.extend(modelJson, App.user());
  },

  render : function() {
    return this.renderTemplate()
  },

  renderTemplate : function(){
    this.template = _.template($(this.template_name).html());
    $(this.el).html(this.template(this.presenter()));
    return this;
  }
});
