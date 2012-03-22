app.views.TemplatePicker = app.views.Base.extend({
  templateName : "template-picker",

  initialize : function(){
    this.model.set({frame_name : 'status'})
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
      templates : [
        "status-with-photo-backdrop",
        "note",
        "rich-media",
        "multi-photo",
        "photo-backdrop",
        "activity-streams-photo",
        "status"
      ]
    })
  }
})