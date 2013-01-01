app.collections.Aspects = Backbone.Collection.extend({
  model: app.models.Aspect,

  selectedAspects: function(attribute){
    return _.pluck(_.filter(this.toJSON(), function(a){
              return a.selected;
      }), attribute);
  },

  allSelected: function(){
    return this.length === _.filter(this.toJSON(), function(a){ return a.selected; }).length;
  },

  selectAll: function(){
    this.map(function(a){ a.set({ 'selected' : true })} );
  },

  deselectAll: function(){
    this.map(function(a){ a.set({ 'selected' : false })} );
  },

  toSentence: function(){
    return this.selectedAspects('name').join(", ").replace(/,\s([^,]+)$/, ' and $1') || 'My Aspects'
  }
})
