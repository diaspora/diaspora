// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.StreamFaces = app.views.Base.extend({

  templateName : "stream-faces",

  className : "stream-faces",

  tooltipSelector : ".avatar",

  initialize : function(){
    this.updatePeople();
    app.stream.items.bind("add", this.updatePeople, this);
    app.stream.items.bind("remove", this.updatePeople, this);
  },

  presenter : function() {
    return {people : this.people};
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
// @license-end
