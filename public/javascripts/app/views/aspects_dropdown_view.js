app.views.AspectsDropdown = app.views.Base.extend({
  templateName : "aspects-dropdown",
  events : {
    "click .dropdown-menu a" : "setVisibility"
  },

  postRenderTemplate : function(){
    this.setVisibility({target : this.$("a[data-visibility='all-aspects']").first()})
  },

  setVisibility : function(evt){
    var self = this
      , link = $(evt.target).closest("a")
      , visibilityCallbacks = {
          'public' : setPublic,
          'all-aspects' : setPrivate,
          'custom' : setCustom
        }

    visibilityCallbacks[link.data("visibility")]()

    this.setAspectIds()

    function setPublic (){
      deselectAll()
      selectAspect()
      self.setDropdownText(link.text())
    }

    function setPrivate (){
      deselectAll()
      selectAspect()
      self.setDropdownText(link.text())
    }

    function setCustom (){
      deselectOverrides()
      link.parents("li").toggleClass("selected")
      self.setDropdownText(link.text())
      evt.stopImmediatePropagation();
    }

    function selectAspect() {
      link.parents("li").addClass("selected")
    }

    function deselectOverrides() {
      self.$("a.public, a.all-aspects").parent().removeClass("selected")
    }

    function deselectAll() {
      self.$("li.selected").removeClass("selected")
    }
  },

  setDropdownText : function(text){
    $.trim(this.$(".dropdown-toggle .text").text(text))
  },

  setAspectIds : function(){
    var selectedAspects = this.$("li.selected a")
    var aspectIds = _.map(selectedAspects, function(aspect){
      return $(aspect).data("aspect-id")}
    )

    this.$("input.aspect_ids").val(aspectIds)
  }
})
