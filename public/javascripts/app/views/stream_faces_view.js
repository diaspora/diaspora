app.views.StreamFaces = app.views.Base.extend({

  template_name : "#stream-faces-template",

  initialize : function(){
    this.updatePeople()
    this.collection.bind("add", this.updatePeople, this)
  },

  presenter : function() {
    return {people : this.people}
  },

  updatePeople : function(){
    if(this.people && this.people.length >= 15) { return }
    this.people = _(this.collection.models).chain()
      .map(function(post){ return post.get("author") })
      .compact()
      .uniq(false, function(person){ return person.id })
      .value()
      .slice(0,15);

    this.render();
  }
})
