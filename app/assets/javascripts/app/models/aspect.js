app.models.Aspect = Backbone.Model.extend({
  toggleSelected: function(){
    this.set({'selected' : !this.get('selected')});
  }
});
