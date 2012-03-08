app.models.StatusMessage = app.models.Post.extend({
  url : function(){
    return this.isNew() ? '/status_messages' : '/posts/' + this.get("id");
  },

  mungeAndSave : function(){
    var mungedAttrs = {
      status_message : _.clone(this.attributes),
      aspect_ids : mungeAspects(this.get("aspect_ids")),
      services : mungeServices(this.get("services"))
    }

    this.save(mungedAttrs)

    function mungeAspects (value){
      return [value]
    }

    function mungeServices (values) {
      return values.length > 1 ?  values :  [values]
    }
  }
});
