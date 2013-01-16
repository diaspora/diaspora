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
    var separator = Diaspora.I18n.t("comma") + ' ';
    return this.selectedAspects('name').join(separator).replace(/,\s([^,]+)$/, ' ' + Diaspora.I18n.t("and") + ' $1') || Diaspora.I18n.t("my_aspects");
  }
})
