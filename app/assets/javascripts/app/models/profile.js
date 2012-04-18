app.models.Profile = Backbone.Model.extend({
  urlRoot : "/profiles"
}, {

  findByGuid : function(personId){
    var person =  new app.models.Profile({ id : personId})
    person.fetch()
    return person
  }
});
