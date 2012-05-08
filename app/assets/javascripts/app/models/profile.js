app.models.Profile = Backbone.Model.extend({
  urlRoot : "/profiles"
}, {

  preloadOrFetch : function(id){
    if(app.hasPreload("person")) {
      return new app.models.Profile(app.parsePreload("person"))
    } else {
      return this.findByGuid(id)
    }
  },

  findByGuid : function(personId){
    var person =  new app.models.Profile({ id : personId})
    person.fetch()
    return person
  }
});
