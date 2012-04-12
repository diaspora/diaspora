app.views.TemplatePicker = app.views.Base.extend({
  templateName : "template-picker",

  events : {
    "click .mood" : "setModelTemplate"
  },

  initialize : function(){
    this.model.setFrameName()
  },

  postRenderTemplate : function(){
    this.setSelectedMoodAttribute()
  },

  setModelTemplate : function(evt){
    evt.preventDefault();
    var selectedMood = $(evt.target);
    this.model.set({"frame_name": selectedMood.data("mood")})
    this.setSelectedMoodAttribute()
  },

  setSelectedMoodAttribute : function(){
    this.$("#selected_mood").removeAttr("id")
    this.$(".mood[data-mood=" + this.model.get("frame_name") + "]").attr("id", "selected_mood")
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      templates : _.union(app.models.Post.frameMoods, _.without(app.models.Post.legacyTemplateNames, ["status", "status-with-photo-backdrop", "photo-backdrop", "activity-streams-photo", "note"])) //subtract re-implemented templates
    })
  }
})