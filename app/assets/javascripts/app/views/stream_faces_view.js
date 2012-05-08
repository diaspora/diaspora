app.views.StreamFaces = app.views.Base.extend({

  templateName : "stream-faces",

  className : "stream-faces",

  tooltipSelector : ".avatar",

  initialize : function(){
    this.updatePeople()
    app.stream.items.bind("add", this.updatePeople, this)
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
});
