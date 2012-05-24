app.models.Profile = Backbone.Model.extend({
  urlRoot : "/profiles"
}, {

  preloadOrFetch : function(id){
    return app.hasPreload("person") ? this.preload() : this.findByGuid(id)
  },

  preload : function(){
    var person = new app.models.Profile(app.parsePreload("person"))
    person.deferred = $.when(true)
    return person
  },

  findByGuid : function(personId){
    var person =  new app.models.Profile({ id : personId})
    person.deferred = person.fetch()
    return person
  }
});
