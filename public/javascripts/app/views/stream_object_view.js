app.views.StreamObject = app.views.Base.extend({
  className : "loaded",

  initialize: function(options) {
    this.model.bind('remove', this.remove, this);
    this.model.bind('change', this.render, this);
  },

  destroyModel: function(evt){
    if(evt){ evt.preventDefault(); }
    if(!confirm("Are you sure?")) { return }

    this.model.destroy();

    $(this.el).slideUp(400, function(){
      $(this).remove();
    });
  }
});
