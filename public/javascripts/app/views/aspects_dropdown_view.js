app.views.AspectsDropdown = app.views.Base.extend({
  templateName : "aspects-dropdown",
  events : {
    "click .dropdown-menu a" : "setVisibility"
  },

  setVisibility : function(evt){
    var linkVisibility = $(evt.target).data("visibility")
      , visibilityCallbacks = {
          'public' : setPublic,
          'all-aspects' : setPrivate
        }

    visibilityCallbacks[linkVisibility].call(this)

    function setPublic (){
      this.setAspectIds("public")
    }

    function setPrivate (){
      this.setAspectIds("all_aspects")
    }
  },

  setAspectIds : function(val){
    this.$("input.aspect_ids").val(val)
  }
})