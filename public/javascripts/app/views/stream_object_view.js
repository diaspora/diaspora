App.Views.StreamObject = App.Views.Base.extend({
  className : "loaded",

  initialize: function(options) {
    this.model.bind('remove', this.remove, this);
    this.model.bind('change', this.render, this);
  },

  destroyModel: function(evt){
    if(evt){ evt.preventDefault(); }
    this.model.destroy();
  }
});
