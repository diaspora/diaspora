app.views.TemplatePicker = app.views.Base.extend({
  templateName : "template-picker",

  initialize : function(){
    this.model.set({frame_name : 'Day'})
  },

  events : {
    "change select" : "setModelTemplate"
  },

  postRenderTemplate : function(){
    this.$("select[name=template]").val(this.model.get("frame_name"))
  },

  setModelTemplate : function(evt){
    this.model.set({"frame_name": this.$("select[name=template]").val()})
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      templates : _.union(app.models.Post.frameMoods, _.without(app.models.Post.legacyTemplateNames, ["status", "status-with-photo-backdrop", "photo-backdrop", "activity-streams-photo"])) //subtract re-implemented templates
    })
  }
})