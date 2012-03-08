app.models.StatusMessage = app.models.Post.extend({
  url : function(){
    return this.isNew() ? '/status_messages' : '/posts/' + this.get("id");
  },

  mungeAndSave : function(){
    var mungedAttrs = {status_message : _.clone(this.attributes), aspect_ids : mungeAspects(this.get("aspect_ids"))}
    this.save(mungedAttrs)

    function mungeAspects (value){
      return [value]
    }
  }
});
