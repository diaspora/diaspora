app.models.StatusMessage = app.models.Post.extend({
  url : function(){
    return this.isNew() ? '/status_messages' : '/posts/' + this.get("id");
  },

  toJSON : function(){
    return {
      status_message : _.clone(this.attributes),
      'aspect_ids' : this.get("aspect_ids").split(","),
      photos : this.photos && this.photos.pluck("id"),
      services : mungeServices(this.get("services"))
    }

    function mungeServices (values) {
      if(!values) { return; }
      return values.length > 1 ?  values :  [values]
    }
  }
});
