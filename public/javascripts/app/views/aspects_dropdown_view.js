app.views.AspectsDropdown = app.views.Base.extend({
  templateName : "aspects-dropdown",
  events : {
    "click .dropdown-menu a" : "setVisibility"
  },

  postRenderTemplate : function(){
    this.setVisibility({target : this.$("a[data-visibility='all-aspects']").first()})
  },

  setVisibility : function(evt){
    var link = $(evt.target)
      , visibilityCallbacks = {
          'public' : setPublic,
          'all-aspects' : setPrivate,
          'custom' : setCustom
        }

    visibilityCallbacks[link.data("visibility") || "all-aspects"].call(this)

    function setPublic (){
      this.setAspectIds("public")
      this.setDropdownText(link.text())
    }

    function setPrivate (){
      this.setAspectIds("all_aspects")
      this.setDropdownText(link.text())
    }

    function setCustom (){
      this.setAspectIds(link.data("aspect-id"))
      this.setDropdownText(link.text())
    }
  },

  setDropdownText : function(text){
    $.trim(this.$(".dropdown-toggle .text").text(text))
  },

  setAspectIds : function(val){
    this.$("input.aspect_ids").val(val)
  }
})