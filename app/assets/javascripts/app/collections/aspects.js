app.collections.Aspects = Backbone.Collection.extend({
  model: app.models.Aspect,

  selectedAspectsIds: function(){
    return _.pluck(_.filter(this.toJSON(), function(a){
              return a.selected;
      }), 'id');
  },

  allSelected: function(){
    return this.length === _.filter(this.toJSON(), function(a){ return a.selected; }).length;
  },

  selectAll: function(){
    this.map(function(a){ a.set({ 'selected' : true })} );
  },

  deselectAll: function(){
    this.map(function(a){ a.set({ 'selected' : false })} );
  }
})
